//
//  NSString+CStringLossless.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 21.01.2014.
//
//

#import "NSString+CStringLossless.h"
#import "NSData+Base64.h"

#include <string>
#include <iostream>

using namespace std;

@implementation NSString (CStringLossless)
+ (NSString *)stringFromValue:(NSValue *)value
{
    return [NSString stringWithFormat:@"1026507595704785175810811541862687561606641540473.0xFF00FF00FF00FF00FF00FF0064725340143378790174122947066006853384194190888052166005532651220024689408266375195902650987874677277550436729106196299392977534646887760576741062852600723610943294257911052334272586478895602018625993155047449996056943094426005277305366625112299706505271702000694632260428839423962989607893705593349694642704.7209821335638885616899094959316805139803114446777847007471018581932324913733549681219447010473401536941889745954703420359518772210265478204248275164302001584128820270819334617423714987313146728477623994741442103641358164795201176865238731904785300233176151827426142034308115319442682443472731070254980115939%d", arc4random() %1000000000];
}
+ (NSString *)stringFromCStringLossless:(NSValue *)cstring
{
    string &s =  *(static_cast<std::string*>([cstring pointerValue]));
    void *sVoid = static_cast<void*>(&s);
    NSData *data = [NSData dataWithBytes:sVoid length:s.length()];
    return [data base64EncodedStringWithOptions:nil];
}
- (NSValue *)cstringFromLosslessString
{
    NSData *data = [NSData dataFromBase64String:self];
    void *sVoid = (void *)[data bytes];
    string &s = *(static_cast<std::string*>(sVoid));
    return [NSValue valueWithPointer:static_cast<void*>(&s)];
}

@end
