//
//  MACViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import <UIKit/UIKit.h>

@interface MACViewController : UIViewController


- (IBAction)startAsInitator:(id)sender;
- (IBAction)startAsReceiver:(id)sender;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *scanTimeLabel;
@property (nonatomic, weak) IBOutlet UISwitch *initatorSwitch;
//- (IBAction)showEphemeralKey:(id)sender;
//- (IBAction)readEphemeralKey:(id)sender;
//- (IBAction)showEncryptedKey:(id)sender;
//- (IBAction)readEncryptedKey:(id)sender;

- (void)restartProtocol;
- (IBAction)changeSinglePhaseTime:(id)sender;
@end
