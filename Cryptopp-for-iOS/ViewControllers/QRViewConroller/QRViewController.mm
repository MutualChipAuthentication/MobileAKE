//
//  QRViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import "QRViewController.h"
#import "SchnorrSigningModel.h"

enum ScanType {
    ScanMessage = 0,
    ScanSignature = 1,
    ScanPublicKey = 2
};


@interface QRViewController ()
@property (nonatomic) ScanType scanType;
@property (nonatomic, strong) NSString *signatureString;
@property (nonatomic, strong) NSString *publicKeyString;
@property (nonatomic, strong) NSString *message;
@end

@implementation QRViewController

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
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Actions
- (IBAction)scanSignature:(id)sender
{
    self.scanType = ScanSignature;
    [self scanQrCode];
}
- (IBAction)scanPublicKey:(id)sender
{
    self.scanType = ScanPublicKey;
    [self scanQrCode];
}
- (IBAction)scanMessage:(id)sender
{
    self.scanType = ScanMessage;
    [self scanQrCode];
}
- (IBAction)verifySignature:(id)sender
{
    if ([SchnorrSigningModel verifySignature:self.signatureString ofMessage:self.message withPubKey:self.publicKeyString])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Signature is valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Signature is invalid" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alertView show];
    }
    
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
            self.message = resultString;
            [self.messageLabel setText:self.message];
            break;
        case ScanSignature:
            self.signatureString = resultString;
            break;
        case ScanPublicKey:
            self.publicKeyString = resultString;
            break;
        default:
            break;
    }
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
