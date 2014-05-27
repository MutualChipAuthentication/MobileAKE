//
//  MACViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import <UIKit/UIKit.h>

@interface MACViewController : UIViewController


- (IBAction)setIsInitalizator:(id)sender;
- (IBAction)generateEphemeralKey:(id)sender;
- (IBAction)verifyEphemeralKey:(id)sender;
- (IBAction)generateAuthenticationData:(id)sender;
- (IBAction)verifyAuthenticationData:(id)sender;
- (IBAction)generateSessionKey:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *qrView;
@property (nonatomic, weak) IBOutlet UILabel *sessionKeyLabel;
@property (weak, nonatomic) IBOutlet UIButton *decryptButton;
@property (weak, nonatomic) IBOutlet UIButton *encryptButton;
@property (weak, nonatomic) IBOutlet UIButton *scanMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *generateSessionButton;

@end
