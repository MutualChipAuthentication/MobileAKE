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
@property (strong, nonatomic) NSString *sessionKey;

- (IBAction)restart:(id)sender;
@end
