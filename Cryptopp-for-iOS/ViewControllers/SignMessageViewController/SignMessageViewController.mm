//
//  SignMessageViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 10.12.2013.
//
//

#import "SignMessageViewController.h"
#import "SchnorrSigningModel.h"
#import <iOS-QR-Code-Encoder/QRCodeGenerator.h>

@interface SignMessageViewController ()
@property (nonatomic, strong) NSDictionary *signatureDictionary;
@property (nonatomic, strong) UIImageView *qrcodeImageView;
@end

@implementation SignMessageViewController
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

- (IBAction)showMessageQr:(id)sender
{
    [self.textField resignFirstResponder];
    SchnorrSigningModel *model = [[SchnorrSigningModel alloc] init];
    self.signatureDictionary = [model createSignatureForMessage:self.textField.text];
    [self encodeQRString:self.signatureDictionary[kMessage]];
}
- (IBAction)showSignatureQR:(id)sender
{
    [self.textField resignFirstResponder];
    [self encodeQRString:self.signatureDictionary[kSignature]];
}
- (IBAction)showPublicKeyQr:(id)sender
{
    [self.textField resignFirstResponder];
    [self encodeQRString:self.signatureDictionary[kPublicKey]];
}

- (void)encodeQRString:(NSString *)stringToEncode
{
    
    int qrcodeImageDimension = min(self.qrView.width, self.qrView.height);

    //then render the matrix
    UIImage* qrcodeImage = [QRCodeGenerator qrImageForString:stringToEncode imageSize:qrcodeImageDimension];
    
    //put the image into the view
    [self.qrcodeImageView removeFromSuperview];
    self.qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
    
    //and that's it!
    [self.qrView addSubview:self.qrcodeImageView];
    [self.qrcodeImageView setX:(self.qrView.width - self.qrcodeImageView.width)/2];
}



@end
