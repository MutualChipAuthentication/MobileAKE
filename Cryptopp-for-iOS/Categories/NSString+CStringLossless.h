//
//  NSString+CStringLossless.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 21.01.2014.
//
//

#import <Foundation/Foundation.h>

@interface NSString (CStringLossless)
+ (NSString *)stringFromCStringLossless:(NSValue *)cstring;
- (NSValue *)cstringFromLosslessString;
+ (NSString *)stringFromValue:(NSValue *)value;
@end
