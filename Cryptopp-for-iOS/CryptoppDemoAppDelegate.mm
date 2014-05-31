//
//  CryptoppDemoAppDelegate.m
//  Cryptopp-for-iOS
//
//  Created by TAKEDA hiroyuki(@3ign0n) on 11/12/23.
//

#import "CryptoppDemoAppDelegate.h"
#import "SchnorrViewController.h"
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [MutualChipAuthentication test];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
