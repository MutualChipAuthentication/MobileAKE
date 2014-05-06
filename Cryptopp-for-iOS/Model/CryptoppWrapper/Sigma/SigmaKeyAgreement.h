//
//  SigmaKeyAgreement.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import <Foundation/Foundation.h>

@interface SigmaKeyAgreement : NSObject
+ (void)simulateProtocol;
- (NSValue *)generateInitialMessage;
- (NSValue *)generateResponse:(NSValue *)message;

- (NSValue *)dsaPubKey;
- (BOOL)verifyResponse:(NSValue *)response message:(NSValue *)message signPubKey:(NSValue *)dsaPubKey;
- (NSValue *)generateSessionSignature:(NSValue *)message andResponse:(NSValue *)response;
- (BOOL)verifySessionSignature:(NSValue *)sessionSignature message:(NSValue *)messageEncoded andResponse:(NSValue *)responseEncoded signPubKey:(NSValue *)dsaPubKeyEncoded;

@end
