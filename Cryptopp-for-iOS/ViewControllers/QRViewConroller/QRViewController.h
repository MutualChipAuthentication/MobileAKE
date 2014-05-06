//
//  QRViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import <UIKit/UIKit.h>

@interface QRViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)scanMessage:(id)sender;
- (IBAction)scanSignature:(id)sender;
- (IBAction)scanPublicKey:(id)sender;
- (IBAction)verifySignature:(id)sender;
@end
