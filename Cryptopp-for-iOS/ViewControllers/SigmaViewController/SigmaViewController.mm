//
//  SigmaViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 06.01.2014.
//
//

#import "SigmaViewController.h"
#import "NSString+CStringLossless.h"
#import "ScannerViewController.h"
#import <iOS-QR-Code-Encoder/QRCodeGenerator.h>
using namespace std;


enum ScanType {
    ScanMessage = 0,
    ScanVerification = 1,
    ScanEstablish = 2
};

@interface SigmaViewController () <ScannerViewDelegate>
@property (nonatomic, strong) SigmaKeyAgreement *sigma;
@property (nonatomic, strong) SigmaKeyAgreement *s2;
@property (nonatomic, strong) NSValue *message;
@property (nonatomic, strong) NSValue *response;
@property (nonatomic, strong) NSValue *sessionsSignature;
@property (nonatomic) ScanType scanType;
@property (nonatomic, strong) UIImageView *qrcodeImageView;
@property (nonatomic, strong) ScannerViewController *scannerViewController;

@end
static int counter;

@implementation SigmaViewController

#pragma mark - View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sigma = [[SigmaKeyAgreement alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)initate:(id)sender
{
    self.message = [self.sigma generateInitialMessage];
    [self encodeQRString:self.message];
    counter = 1;
}
- (IBAction)verify:(id)sender
{
    self.scanType = ScanMessage;
    [self scanQrCode];
    counter++;
}
- (IBAction)establish:(id)sender
{
//    self.message = [self.sigma generateInitialMessage];
//    self.response = [self.s2 generateResponse:self.message];
//    NSValue *string = [self.sigma generateSessionSignature:self.message andResponse:self.response];
//    [self encodeQRString:string];
    [self showAlert:@"Scan ok" message:@"Session key established"];
    counter++;
}

#pragma mark - helpers
- (void)scanQrCode
{
    [self.activityIndicator startAnimating];
    self.scannerViewController = [[ScannerViewController alloc] initWithNibName:@"ScannerViewController" bundle:nil];
    [self.scannerViewController setDelegate:self];
    [self presentViewController:self.scannerViewController animated:YES completion:nil];
}

#pragma mark ScannerViewDelegate
- (void)didScanResult:(NSString *)resultString
{
    switch (self.scanType) {
        case ScanMessage:
            self.response = [self.s2 generateResponse:self.message];
            [self encodeQRString:self.response];
            break;
        case ScanVerification:
            self.sessionsSignature = [self.sigma generateSessionSignature:self.message andResponse:self.response];
            [self encodeQRString:self.sessionsSignature];
            break;
        case ScanEstablish:
            [self showAlert:@"Scan ok" message:@"Session key established"];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Helpers

- (void)encodeQRString:(NSValue *)stringToEncode
{
    int qrcodeImageDimension = fmin(self.qrView.width, self.qrView.height);
    
    //first encode the string into a matrix of bools, TRUE for black dot and FALSE for white. Let the encoder decide the error correction level and version
    NSString *encodedString = [NSString stringFromValue:stringToEncode];
    
    //then render the matrix
    UIImage* qrcodeImage = [QRCodeGenerator qrImageForString:encodedString imageSize:qrcodeImageDimension];
    
    //put the image into the view
    [self.qrcodeImageView removeFromSuperview];
    self.qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
    
    //and that's it!
    [self.qrView addSubview:self.qrcodeImageView];
    [self.qrcodeImageView setX:(self.qrView.width - self.qrcodeImageView.width)/2];
}


@end
