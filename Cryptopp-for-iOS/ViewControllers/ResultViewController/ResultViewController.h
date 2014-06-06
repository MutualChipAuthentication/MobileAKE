//
//  ResultViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 27/05/14.
//
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *sessionKeyView;
@property (weak, nonatomic) IBOutlet UILabel *cryptoComputationTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *protocolRunTimeLabel;
@property (strong, nonatomic) NSString *sessionKey;
@property (nonatomic, assign) NSTimeInterval cryptoComputionTime;
@property (nonatomic, assign) NSTimeInterval protocolRunTime;


- (IBAction)restart:(id)sender;
@end
