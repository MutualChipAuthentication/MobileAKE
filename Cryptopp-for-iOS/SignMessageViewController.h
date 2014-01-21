//
//  SignMessageViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 10.12.2013.
//
//

#import <UIKit/UIKit.h>

@interface SignMessageViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIView *qrView;
@property (nonatomic, weak) IBOutlet UITextField *textField;

- (IBAction)showMessageQr:(id)sender;
- (IBAction)showSignatureQR:(id)sender;
- (IBAction)showPublicKeyQr:(id)sender;

@end
