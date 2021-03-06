//
//  SigmaViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 06.01.2014.
//
//

#import <UIKit/UIKit.h>
#import "SigmaKeyAgreement.h"


@interface SigmaViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIView *qrView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)initate:(id)sender;
- (IBAction)verify:(id)sender;
- (IBAction)establish:(id)sender;
@end
