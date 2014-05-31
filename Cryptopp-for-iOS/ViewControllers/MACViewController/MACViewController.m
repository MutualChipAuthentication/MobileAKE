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


const int kSingleProtocolPhaseTime = 6;

typedef enum : NSUInteger {
    ScanTypeMessage,
    ScanTypeEstablish,
} ScanType;

@interface MACViewController () <ScannerViewDelegate>
@property (nonatomic, strong) MutualChipAuthentication *MAC;
@property (nonatomic, strong) UIImageView *qrcodeImageView;
@property (nonatomic, assign) ScanType scanType;
@property (nonatomic, strong) NSArray *protocolMethods;
@end

@implementation MACViewController
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions
- (IBAction)startAsInitator:(id)sender
{
    _MAC = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:YES];
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

static int counter = 0;




#pragma mark - Protocol run
- (void)generateEphemeralKeyWithCompletion:(void (^)(void))completion
{
    NSString *ephemeralKey = [self.MAC generateInitalMessage];
    NSLog(@"ephemeral key %@", ephemeralKey);
    [self showQRString:ephemeralKey completion:completion];
}
- (void)verifyEphemeralKeyWithCompletion:(void (^)(void))completion
{
    _scanType = ScanTypeMessage;
    [self scanQrCodeWithCompletion:^{
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
    NSString *authenticationData = [self.MAC generateMessage];
    [self showQRString:authenticationData completion:completion];
}
- (void)verifyAuthenticationDataWithCompletion:(void (^)(void))completion
{
    _scanType = ScanTypeEstablish;
    [self scanQrCodeWithCompletion:completion];
}

- (void)restartProtocol
{
    [self dismissViewControllerAnimated:YES completion:nil];
    DLog(@"restart protocol");
}

#pragma mark ScannerViewDelegate
- (void)didScanResult:(NSString *)resultString
{
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
    UIStoryboard *procolStoryboard = [UIStoryboard procolStoryboard];
    ScannerViewController *scannerViewController = [procolStoryboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    [scannerViewController setDelegate:self];
    [self presentViewController:scannerViewController animated:YES completion:^{
        [scannerViewController startRunning];
        [self dissmissViewAfterDelay:kSingleProtocolPhaseTime withCompletion:completion];
    }];
}

- (void)dissmissViewAfterDelay:(int)delayInSeconds withCompletion:(void (^)(void))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:completion];
    });
}

- (void)showResult:(NSString *)sessionKey
{
    NSLog(@"established session key %@", sessionKey);
    UIStoryboard *procolStoryboard = [UIStoryboard procolStoryboard];
    ResultViewController *resultViewController = [procolStoryboard instantiateViewControllerWithIdentifier:@"ResultViewController"];
    [resultViewController setSessionKey:sessionKey];
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


#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
