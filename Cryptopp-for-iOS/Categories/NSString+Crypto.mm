//
//  NSString+Crypto.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import "NSString+Crypto.h"
#import "NSString+CStringLossless.h"
#include <cryptopp/integer.h>

#include <sstream>

using namespace std;

@implementation NSString (Crypto)
+ (NSString *)stringWithDefaultCString:(std::string)decodedString
{
    NSValue *stringAsValue = [NSValue valueWithPointer:new string(decodedString)];
    return [NSString stringFromCStringLossless:stringAsValue];
}

+ (NSString *)stringWithInteger:(CryptoPP::Integer)i
{
    ostringstream oss;
    oss << i;
    string iString = oss.str();
    return [NSString stringWithDefaultCString:iString];
}
- (CryptoPP::Integer)cryptoIntegerValue
{
    string encodedString = [self defaultCString];
    return CryptoPP::Integer(encodedString.c_str());
}
- (std::string)defaultCString
{
    NSValue *decodedString = [self cstringFromLosslessString];
    string encodedCString = *((string *)[decodedString pointerValue]);
    return encodedCString;
}

@end
