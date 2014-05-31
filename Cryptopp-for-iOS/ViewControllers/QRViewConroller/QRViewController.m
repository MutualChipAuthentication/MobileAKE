//
//  QRViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 27/05/14.
//
//

#import "QRViewController.h"
#import "ScannerViewController.h"
#import <iOS-QR-Code-Encoder/QRCodeGenerator.h>

@interface QRViewController ()
@property (nonatomic, strong) UIImageView *qrcodeImageView;
@end

@implementation QRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self displayQRString];
}

#pragma mark - Helpers
- (void)displayQRString
{
    int qrcodeImageDimension = fmin(self.qrView.width, self.qrView.height);

    //then render the matrix
    UIImage* qrcodeImage = [QRCodeGenerator qrImageForString:self.encodedString imageSize:qrcodeImageDimension];
    
    //put the image into the view
    [self.qrcodeImageView removeFromSuperview];
    self.qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
    
    //and that's it!
    [self.qrView addSubview:self.qrcodeImageView];
    [self.qrcodeImageView setX:(self.qrView.width - self.qrcodeImageView.width)/2];
}

@end
