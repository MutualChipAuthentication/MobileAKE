//
//  ScannerViewController.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 21/04/14.
//
//

#import <UIKit/UIKit.h>

@protocol ScannerViewDelegate <NSObject>
- (void)didScanResult:(NSString *)resultString;
- (void)didCancel;
@end

@interface ScannerViewController : UIViewController
@property (nonatomic, weak) id<ScannerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
- (void)startScanning;
- (void)startRunning;
- (void)stopRunning;
- (IBAction)dissmiss:(id)sender;
@end
