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
#include "base64.h"
#import "NSData+Base64.h"
#include <sstream>
#include <iostream>


using namespace std;

@implementation NSString (Crypto)
+ (NSString *)stringWithDefaultCString:(std::string)decodedString
{
    string encoded = base64_encode((unsigned char const* )decodedString.c_str(), (unsigned int)decodedString.size());
    string afterDecode = base64_decode(encoded);
    return @(encoded.c_str());
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
    string decoded = base64_decode([self cStringUsingEncoding:NSASCIIStringEncoding]);
    return decoded;
}

@end
