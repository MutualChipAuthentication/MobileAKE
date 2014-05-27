//
//  SchnorrSigningModel.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 10.12.2013.
//
//

#import <Foundation/Foundation.h>
#include "SchnorrSignature.h"

UIKIT_EXTERN NSString *const kSignature;
UIKIT_EXTERN NSString *const kMessage;
UIKIT_EXTERN NSString *const kPublicKey;


@interface SchnorrSigningModel : NSObject
- (NSDictionary *)createSignatureForMessage:(NSString *)message;
- (void)test;
+ (BOOL)verifySignature:(NSString *)signature ofMessage:(NSString *)message withPubKey:(NSString *)publicKey;

@end
