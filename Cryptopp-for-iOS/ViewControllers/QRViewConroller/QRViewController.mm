//
//  QRViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import "QRViewController.h"
#import "SchnorrSigningModel.h"
#import "ScannerViewController.h"

enum ScanType {
    ScanMessage = 0,
    ScanSignature = 1,
    ScanPublicKey = 2
};


@interface QRViewController () <ScannerViewDelegate>

@property (nonatomic) ScanType scanType;
@property (nonatomic, strong) NSString *signatureString;
@property (nonatomic, strong) NSString *publicKeyString;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) ScannerViewController *scannerViewController;
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

#pragma mark - Helpers
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

- (void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
