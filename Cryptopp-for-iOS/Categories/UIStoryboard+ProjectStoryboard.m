//
//  UIStoryboard+ProjectStoryboard.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import "UIStoryboard+ProjectStoryboard.h"

@implementation UIStoryboard (ProjectStoryboard)
+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
}
+ (UIStoryboard *)procolStoryboard
{
    return [UIStoryboard storyboardWithName:@"MACStoryboard" bundle:nil];
}

@end
