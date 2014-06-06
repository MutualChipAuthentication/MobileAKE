//
//  MACViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import "MACViewController.h"
#import "MutualChipAuthentication.h"
#import "QRViewController.h"
#import "ScannerViewController.h"
#import "ResultViewController.h"
#import "UIStoryboard+ProjectStoryboard.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>


const float kInitialSingleProtocolPhaseTime = 6.0;
float kSingleProtocolPhaseTime = 6.0;


typedef enum : NSUInteger {
    ScanTypeMessage,
    ScanTypeEstablish,
} ScanType;

@interface MACViewController () <ScannerViewDelegate>
@property (nonatomic, strong) MutualChipAuthentication *MAC;
@property (nonatomic, strong) ScannerViewController *scannerViewController;
@property (nonatomic, strong) UIImageView *qrcodeImageView;
@property (nonatomic, assign) ScanType scanType;
@property (nonatomic, strong) NSArray *protocolMethods;
@property (nonatomic, assign) NSTimeInterval cryptographicOperationsExecutionTime;
@property (nonatomic, assign) NSTimeInterval scanningQRExectionTime;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, assign) double lowPassResults;

@end

@implementation MACViewController
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"device id %@", [[NSUUID UUID] UUIDString]);
    //9405BB2B-1500-42A1-8715-411560744428 - iphone pawelqus
    //EBFFF78B-EFF0-4790-9236-48A2E6870561
    kSingleProtocolPhaseTime = kInitialSingleProtocolPhaseTime;
    self.scanningQRExectionTime = 0;
    self.cryptographicOperationsExecutionTime = 0;
    [self initializeRecording];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    kSingleProtocolPhaseTime = self.slider.value;
    NSLog(@"scan time %lf", kSingleProtocolPhaseTime);
    self.scanTimeLabel.text = [NSString stringWithFormat:@"Scan time: %.2f", kSingleProtocolPhaseTime];
}

#pragma mark - Actions
- (IBAction)startAsInitator:(id)sender
{
    NSLog(@"start as initator");
    [NSThread sleepForTimeInterval:1.0f];
    AudioServicesPlaySystemSound(1004);
    NSDate *methodStart = [NSDate date];
    _MAC = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:YES];
    NSDate *methodFinish = [NSDate date];
    self.cryptographicOperationsExecutionTime = [methodFinish timeIntervalSinceDate:methodStart];

    [self generateEphemeralKeyWithCompletion:^{
        [self verifyEphemeralKeyWithCompletion:^{
            [self generateAuthenticationDataWithCompletion:^{
                [self verifyAuthenticationDataWithCompletion:^{
                    if (self.MAC.encryptionKeyOtherParty != nil)
                    {
                        [self showResult:[self.MAC generateSessionKey]];
                    }
                }];
            }];
        }];
    }];
}
- (IBAction)startAsReceiver:(id)sender
{
    NSLog(@"start as receiver");
    [NSThread sleepForTimeInterval:1.0f];
    AudioServicesPlaySystemSound(1004);
    _MAC = [[MutualChipAuthentication alloc] initWithName:@"B" isInitator:NO];
    [self verifyEphemeralKeyWithCompletion:^{
        [self generateEphemeralKeyWithCompletion:^{
            [self verifyAuthenticationDataWithCompletion:^{
                [self generateAuthenticationDataWithCompletion:^{
                    if (self.MAC.encryptionKeyOtherParty != nil)
                    {
                        [self showResult:[self.MAC generateSessionKey]];
                    }
                }];
            }];
        }];
    }];
}

- (IBAction)changeSinglePhaseTime:(id)sender
{
    kSingleProtocolPhaseTime = self.slider.value;
    self.scanTimeLabel.text = [NSString stringWithFormat:@"Scan time: %.2f", kSingleProtocolPhaseTime];
}

static int counter = 0;




#pragma mark - Protocol run
- (void)generateEphemeralKeyWithCompletion:(void (^)(void))completion
{
    NSDate *methodStart = [NSDate date];
    NSString *ephemeralKey = [self.MAC generateInitalMessage];
    NSDate *methodFinish = [NSDate date];
    self.cryptographicOperationsExecutionTime += [methodFinish timeIntervalSinceDate:methodStart];

    NSLog(@"ephemeral key %@", ephemeralKey);
    [self showQRString:ephemeralKey completion:completion];
}
- (void)verifyEphemeralKeyWithCompletion:(void (^)(void))completion
{
    _scanType = ScanTypeMessage;
    NSDate *methodStart = [NSDate date];
    [self scanQrCodeWithCompletion:^{
        NSDate *methodFinish = [NSDate date];
        self.scanningQRExectionTime += [methodFinish timeIntervalSinceDate:methodStart];

        if (self.MAC.ephemeralKeyOtherParty != nil)
        {
            if (completion)
                completion();
        }
        else
        {
            [self restartProtocol];
        }
    }];
}

- (void)generateAuthenticationDataWithCompletion:(void (^)(void))completion
{
    NSDate *methodStart = [NSDate date];
    NSString *authenticationData = [self.MAC generateMessage];
    NSDate *methodFinish = [NSDate date];
    self.cryptographicOperationsExecutionTime += [methodFinish timeIntervalSinceDate:methodStart];
    [self showQRString:authenticationData completion:completion];
}
- (void)verifyAuthenticationDataWithCompletion:(void (^)(void))completion
{
    _scanType = ScanTypeEstablish;
    NSDate *methodStart = [NSDate date];
    [self scanQrCodeWithCompletion:^{
        NSDate *methodFinish = [NSDate date];
        self.scanningQRExectionTime += [methodFinish timeIntervalSinceDate:methodStart];
        if (completion)
            completion();
    }];
}

- (void)restartProtocol
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.cryptographicOperationsExecutionTime = 0;
    self.scanningQRExectionTime = 0;
    DLog(@"restart protocol");
    [self initializeRecording];
}

#pragma mark ScannerViewDelegate
- (void)didScanResult:(NSString *)resultString
{
    NSLog(@"did scan");
    AudioServicesPlaySystemSound(1108);
    NSDate *methodStart = [NSDate date];
    switch (self.scanType) {
        case ScanTypeMessage:
            NSLog(@"ephemeral key %@", resultString);
            [self.MAC setEphemeralKeyOtherParty:resultString];
            break;
        case ScanTypeEstablish:
            NSLog(@"encrypted key %@", resultString);
            [self.MAC setEncryptionKeyOtherParty:resultString];
            break;
        default:
            break;
    }
    NSDate *methodFinish = [NSDate date];
    self.cryptographicOperationsExecutionTime += [methodFinish timeIntervalSinceDate:methodStart];
}

- (void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers
- (void)showQRString:(NSString *)encodedString completion:(void (^)(void))completion
{
    UIStoryboard *procolStoryboard = [UIStoryboard procolStoryboard];
    QRViewController *qrViewController = [procolStoryboard instantiateViewControllerWithIdentifier:@"QRViewController"];
    [qrViewController setEncodedString:encodedString];
    
    [self presentViewController:qrViewController animated:NO completion:^{
        [self dissmissViewAfterDelay:kSingleProtocolPhaseTime withCompletion:completion];
    }];
}

- (void)scanQrCodeWithCompletion:(void (^)(void))completion
{
    if (_scannerViewController == nil)
    {
        UIStoryboard *procolStoryboard = [UIStoryboard procolStoryboard];
        _scannerViewController = [procolStoryboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
        [_scannerViewController setDelegate:self];
    }
    [self presentViewController:_scannerViewController animated:NO completion:^{
        [_scannerViewController startRunning];
        [_scannerViewController startScanning];
        [self dissmissViewAfterDelay:kSingleProtocolPhaseTime withCompletion:completion];
    }];
}

- (void)dissmissViewAfterDelay:(int)delayInSeconds withCompletion:(void (^)(void))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:completion];
    });
}

- (void)showResult:(NSString *)sessionKey
{
    NSLog(@"established session key %@", sessionKey);
    UIStoryboard *procolStoryboard = [UIStoryboard procolStoryboard];
    ResultViewController *resultViewController = [procolStoryboard instantiateViewControllerWithIdentifier:@"ResultViewController"];
    [resultViewController setSessionKey:sessionKey];
    [resultViewController setProtocolRunTime:self.scanningQRExectionTime + self.cryptographicOperationsExecutionTime];
    [resultViewController setCryptoComputionTime:self.cryptographicOperationsExecutionTime];
     [self presentViewController:resultViewController animated:YES completion:nil];
}

#pragma mark - Actions
- (IBAction)showEphemeralKey:(id)sender
{
    if (counter == 0)
        _MAC = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:YES];
    else
        _MAC = [[MutualChipAuthentication alloc] initWithName:@"B" isInitator:NO];
    
    [self generateEphemeralKeyWithCompletion:nil];
    counter++;
}
- (IBAction)readEphemeralKey:(id)sender
{
    if (counter == 0)
        _MAC = [[MutualChipAuthentication alloc] initWithName:@"B" isInitator:NO];
    else
        _MAC = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:YES];
    
    [self verifyEphemeralKeyWithCompletion:nil];
    counter++;
}
- (IBAction)showEncryptedKey:(id)sender
{
    [self generateAuthenticationDataWithCompletion:nil];
}
- (IBAction)readEncryptedKey:(id)sender
{
    [self verifyAuthenticationDataWithCompletion:nil];
}

#pragma mark - Helpers
- (void)initializeRecording
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	_recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
  	if (_recorder) {
  		[_recorder prepareToRecord];
  		_recorder.meteringEnabled = YES;
  		[_recorder record];
		_levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(listenForBlow:) userInfo: nil repeats: YES];
  	} else
  		NSLog(@"error initializing microphone %@", [error description]);
}

- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
	_lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * _lowPassResults;
    
	NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [self.recorder averagePowerForChannel:0], [self.recorder peakPowerForChannel:0], self.lowPassResults);
}

- (void)listenForBlow:(NSTimer *)timer {
	[self.recorder updateMeters];
    
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
	_lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * _lowPassResults;
	NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [self.recorder averagePowerForChannel:0], [self.recorder peakPowerForChannel:0], self.lowPassResults);
    
	if (_lowPassResults > 0.60)
    {
		NSLog(@"Mic blow detected");
        [self.levelTimer invalidate];
        self.levelTimer = nil;
        [self.recorder stop];
        self.recorder = nil;
        [self initiateProtocol];
    }
}

- (void)initiateProtocol
{
    if (self.initatorSwitch.on)
        [self startAsInitator:nil];
    else
        [self startAsReceiver:nil];
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
