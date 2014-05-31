//
//  QRViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 27/05/14.
//
//

#import <UIKit/UIKit.h>

@interface QRViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *qrView;
@property (strong, nonatomic) NSString *encodedString;
@end
