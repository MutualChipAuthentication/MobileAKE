//
//  SigmaViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 06.01.2014.
//
//

#import "SigmaViewController.h"
#import "NSString+CStringLossless.h"
using namespace std;

#import <QREncoder.h>

enum ScanType {
    ScanMessage = 0,
    ScanVerification = 1,
    ScanEstablish = 2
};

@interface SigmaViewController ()
@property (nonatomic, strong) SigmaKeyAgreement *sigma;
@property (nonatomic, strong) SigmaKeyAgreement *s2;
@property (nonatomic, strong) NSValue *message;
@property (nonatomic, strong) NSValue *response;
@property (nonatomic, strong) NSValue *sessionsSignature;
@property (nonatomic) ScanType scanType;
@property (nonatomic, strong) UIImageView *qrcodeImageView;

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
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        ZXingWidgetController * widController = [[ZXingWidgetController alloc] initWithDelegate:self
                                                                                     showCancel:YES
                                                                                       OneDMode:NO
                                                                                    showLicense:NO];
        
        MultiFormatReader* qrcodeReader = [[MultiFormatReader alloc] init];
        NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
        widController.readers = readers;
        
        widController.overlayView.displayedMessage = @"";
        widController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [widController addNavigationBar];
            [self presentViewController:widController animated:NO completion:^{
                [self.activityIndicator stopAnimating];
            }];
        });
    });
}

#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)resultString {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *lastCode = [preferences objectForKey:@"lastCode"];
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

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
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
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:encodedString];
    
    //then render the matrix
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    //put the image into the view
    [self.qrcodeImageView removeFromSuperview];
    self.qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
    
    //and that's it!
    [self.qrView addSubview:self.qrcodeImageView];
    [self.qrcodeImageView setX:(self.qrView.width - self.qrcodeImageView.width)/2];
}


@end
