//
//  NSString+Crypto.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import <Foundation/Foundation.h>
#include <cryptopp/integer.h>

@interface NSString (Crypto)
+ (NSString *)stringWithDefaultCString:(std::string)string;
- (std::string)defaultCString;
+ (NSString *)stringWithInteger:(CryptoPP::Integer)i;
- (CryptoPP::Integer)cryptoIntegerValue;
@end
