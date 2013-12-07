//
//  QRViewController.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import "QRViewController.h"
#import "SigmaKeyAgreement.h"

@interface QRViewController ()

@end

@implementation QRViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)startProtocol:(id)sender
{
    SigmaKeyAgreement *protocol = [[SigmaKeyAgreement alloc] init];
    [protocol simulateProtocol];
}
- (IBAction)scanQrCode:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        ZXingWidgetController * widController = [[ZXingWidgetController alloc] initWithDelegate:self
                                                                                     showCancel:YES
                                                                                       OneDMode:NO
                                                                                    showLicense:NO];
        
        MultiFormatReader* qrcodeReader = [[MultiFormatReader alloc] init];
        NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
        widController.readers = readers;
        
        widController.overlayView.displayedMessage = @"";
        widController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [widController addNavigationBar];
        });
    });
}

#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)resultString {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *lastCode = [preferences objectForKey:@"lastCode"];
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
