//
//  MACViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import "MACViewController.h"
#import "NSString+CStringLossless.h"
#import "MutualChipAuthentication.h"
#import <iOS-QR-Code-Encoder/QRCodeGenerator.h>
#import "ScannerViewController.h"
#import "UIStoryboard+ProjectStoryboard.h"


typedef enum : NSUInteger {
    ScanTypeMessage,
    ScanTypeEstablish,
} ScanType;

@interface MACViewController () <ScannerViewDelegate>
@property (nonatomic, strong) MutualChipAuthentication *MAC;
@property (nonatomic, strong) UIImageView *qrcodeImageView;
@property (nonatomic, assign) ScanType scanType;
@end

@implementation MACViewController
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _MAC = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:YES];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions
- (IBAction)setIsInitalizator:(UISwitch *)sender
{
    _MAC = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:sender.selected];
}
- (IBAction)generateEphemeralKey:(id)sender
{
    NSString *ephemeralKey = [self.MAC generateInitalMessage];
    [self encodeQRString:ephemeralKey];
}
- (IBAction)verifyEphemeralKey:(id)sender
{
    _scanType = ScanTypeMessage;
    [self scanQrCode];
}
- (IBAction)generateAuthenticationData:(id)sender
{
    NSString *authenticationData = [self.MAC generateMessage];
    [self encodeQRString:authenticationData];
}
- (IBAction)verifyAuthenticationData:(id)sender
{
    _scanType = ScanTypeEstablish;
    [self scanQrCode];
}
- (IBAction)generateSessionKey:(id)sender
{
    self.sessionKeyLabel.text = [self.MAC generateSessionKey];
}

#pragma mark ScannerViewDelegate
- (void)didScanResult:(NSString *)resultString
{
    switch (self.scanType) {
        case ScanTypeMessage:
            [self.MAC setEphemeralKeyOtherParty:resultString];
            break;
        case ScanTypeEstablish:
            [self.MAC setEncryptionKeyOtherParty:resultString];
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

#pragma mark - Helpers
- (void)encodeQRString:(NSString *)encodedString
{
    int qrcodeImageDimension = fmin(self.qrView.width, self.qrView.height);
    
    UIImage* qrcodeImage = [QRCodeGenerator qrImageForString:encodedString imageSize:qrcodeImageDimension];
    
    //put the image into the view
    [self.qrcodeImageView removeFromSuperview];
    self.qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
    
    //and that's it!
    [self.qrView addSubview:self.qrcodeImageView];
    [self.qrcodeImageView setX:(self.qrView.width - self.qrcodeImageView.width)/2];
}

- (void)scanQrCode
{
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    ScannerViewController *scannerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    [scannerViewController setDelegate:self];
    [self presentViewController:scannerViewController animated:YES completion:^{
        [scannerViewController startRunning];
    }];
}


#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
