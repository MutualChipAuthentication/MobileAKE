//
//  MutualChipAuthentication.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#include "MutualAuthenticationChip.h"
#import <Foundation/Foundation.h>

@interface MutualChipAuthentication : NSObject

- (id)initWithName:(NSString *)name isInitator:(BOOL)isInitator;
- (NSString *)generateInitalMessage;
- (NSString *)generateMessage;
- (NSString *)generateSessionKey;
+ (void)test;

@property (nonatomic, readonly) NSString *publicKey;
@property (nonatomic, readonly) NSString *ephemeralPublicKey;
@property (nonatomic, strong) NSDictionary *otherPartyPublicData;
@property (nonatomic, strong) NSString *ephemeralKeyOtherParty;
@property (nonatomic, strong) NSString *encryptionKeyOtherParty;
@end
