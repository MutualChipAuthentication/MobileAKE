//
//  ScannerViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 21/04/14.
//
//

#import "ScannerViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic) BOOL isReading;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation ScannerViewController

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _captureSession = nil;
    _isReading = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_once(&_onceToken, ^{
        [self addScanPointer];
    });
}

#pragma mark - Actions
- (void)dissmiss
{
    [self.delegate didCancel];
}

#pragma mark - Video Preview Control
- (void)startRunning
{
    if (self.isReading)
        return;
    
    _queue = dispatch_queue_create("qrScanner", NULL);
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
    {
        DLog(@"error %@", [error localizedDescription]);
        return;
    }
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([_captureSession canAddOutput:_captureMetadataOutput])
        [_captureSession addOutput:_captureMetadataOutput];
    else
        return;
    
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:_queue];
    [_captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:1];
    
    dispatch_async(_queue, ^{
        [_captureSession startRunning];
    });
    _isReading = YES;
}
- (void)stopRunning
{
    if (!self.isReading)
        return;
    dispatch_async(_queue, ^{
        NSLog(@"capture session %@", self.captureSession);
        [self.captureSession stopRunning];
        self.captureSession = nil;
    });
    [self.videoPreviewLayer removeFromSuperlayer];
    self.isReading = NO;
}

- (void)startScanning
{
    if (self.isReading && [_captureSession canAddOutput:_captureMetadataOutput])
    {
        [_captureSession addOutput:_captureMetadataOutput];
    }
}

- (void)stopScanning
{
    if (self.isReading)
    {
        [_captureSession removeOutput:_captureMetadataOutput];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataCode = metadataObjects.firstObject;
        if ([[metadataCode type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didScanResult:[metadataCode stringValue]];
                [self stopScanning];
            });
        }
    }
}

#pragma mark - Helpers
/*!
 *  Adds customized overlay view on top of the scanning view
 */
- (void)addScanPointer
{
    UIImage *image = [UIImage imageNamed:@"scan-pointer"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:imageView];
    [imageView setCenter:self.view.center];
}


#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
