//
//  CryptoppDemoAppDelegate.m
//  Cryptopp-for-iOS
//
//  Created by TAKEDA hiroyuki(@3ign0n) on 11/12/23.
//

#import "CryptoppDemoAppDelegate.h"
#import "QRViewController.h"
#import "SignMessageViewController.h"
#import "SigmaViewController.h"
#import "Converter.h"

#include "AKETest.h"
#include "SchnorrSignature.h"
//#import "CryptoppHash.h"
//#import "HashClass.h"

#include "MutualChipAuthentication.h"
#include "Sigma.h"


@implementation CryptoppDemoAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        SigmaViewController *sigmaViewController = [[SigmaViewController alloc] initWithNibName:@"SigmaViewController" bundle:nil];
//        
//        
//        QRViewController *qrViewController = [[QRViewController alloc] initWithNibName:@"QRViewController" bundle:nil];
//        self.navigationController = [[UINavigationController alloc] initWithRootViewController:qrViewController];
//        
//        SignMessageViewController *signMessageViewController = [[SignMessageViewController alloc] initWithNibName:@"SignMessageViewController" bundle:nil];
//        
//        UITabBarController *tabBarController = [[UITabBarController alloc] init];
//        [tabBarController setViewControllers:@[sigmaViewController, signMessageViewController, qrViewController]];
//        self.window.rootViewController = tabBarController;
    }
    [MutualChipAuthentication test2];
    Converter::test();
    MutualAuthenticationChip::test();
//    Sigma::test();
//    [SigmaKeyAgreement simulateProtocol];
//    SchnorrSigningModel *schnorr = [[SchnorrSigningModel alloc] init];
//    [schnorr test];
//    AKETest::test();

//    CryptoppSHA *sha = [[CryptoppSHA alloc] initWithLength:CryptppSHALength1];
//    NSString *message = @"hello";
//    NSData *messageData = [message dataUsingEncoding:NSASCIIStringEncoding];
//    NSData *messageOutput = [sha getHashValue:messageData];
//    NSLog(@"sha(%@) = %@", message, messageOutput);
//    byte *result = HashClass::getSHA1((const byte *)messageData.bytes, messageData.length);
//    messageOutput = [NSData dataWithBytes:result length:20];
//    NSLog(@"sha(%@) = %@", message, messageOutput);
//    result = HashClass::getSHA1((const byte *)messageData.bytes, messageData.length);
//    messageOutput = [NSData dataWithBytes:result length:20];
//    NSLog(@"sha(%@) = %@", message, messageOutput);
//    
//    SchnorrSign::test();
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
