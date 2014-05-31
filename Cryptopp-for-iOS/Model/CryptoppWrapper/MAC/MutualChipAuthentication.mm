//
//  MutualChipAuthentication.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 24/05/14.
//
//

#import "MutualChipAuthentication.h"
#import "NSString+Crypto.h"

using namespace std;
using CryptoPP::AutoSeededRandomPool;


NSString *const kCertificate = @"certificate";
NSString *const kPublicKey = @"publicKey";

@interface MutualChipAuthentication ()
{
    MutualAuthenticationChip *MAC;
    SecByteBlock *sessionKey;
}
@property (nonatomic, assign) BOOL isInitator;
@end

@implementation MutualChipAuthentication

- (id)initWithName:(NSString *)name isInitator:(BOOL)isInitator
{
    self = [super init];
    if (self)
    {
        AutoSeededRandomPool rnd;
        MAC = new MutualAuthenticationChip(rnd, [name cStringUsingEncoding:NSASCIIStringEncoding]);
        [self setOtherPartyPublicData:@{kPublicKey:[self otherPartyPublicKey]}];
        _isInitator = isInitator;
    }
    return self;
}

+ (void)test
{
    MutualChipAuthentication *partA = [[MutualChipAuthentication alloc] initWithName:@"A" isInitator:YES];
    MutualChipAuthentication *partB = [[MutualChipAuthentication alloc] initWithName:@"B" isInitator:NO];
    
    NSString *ephemeralKeyA = [partA generateInitalMessage];
    NSLog(@"ephemeral key A %@", ephemeralKeyA);
    [partB setEphemeralKeyOtherParty:ephemeralKeyA];
    NSString *ephemeralKeyB = [partB generateInitalMessage];
    NSLog(@"ephemeral key B %@", ephemeralKeyB);
    [partA setEphemeralKeyOtherParty:ephemeralKeyB];
    NSString *encryptKeyA = [partA generateMessage];
    [partB setEncryptionKeyOtherParty:encryptKeyA];
    NSString *encryptKeyB = [partB generateMessage];
    [partA setEncryptionKeyOtherParty:encryptKeyB];
    
    NSString *sessionKeyA = [partA generateSessionKey];
    NSString *sesssionKeyB = [partB generateSessionKey];
    NSLog(@"session keys %@ %@", sessionKeyA, sesssionKeyB);
}

- (NSString *)generateInitalMessage
{
    return [self ephemeralPublicKey];
}

- (NSString *)generateMessage
{
    NSString *result = nil;
    if (self.isInitator)        //partA
    {
        result = [NSString stringWithDefaultCString:MAC->EncryptCertKey()];
    }
    else if ([self verifyMessage:self.encryptionKeyOtherParty])   //part B
    {
        result = [NSString stringWithDefaultCString:MAC->EncryptCertKey()];
    }
    return result;
}

- (BOOL)verifyMessage:(NSString *)message   //part B
{
    string cipher = [message defaultCString];
    return (MAC->DecryptCertKey(cipher) == true);
}

- (NSString *)verifyAndGenerateSessionKey:(NSString *)message   //part A
{
    if (self.isInitator == YES && [self verifyMessage:message])
        return [self generateSessionKey];
    else
        return nil;
}

- (void)setEphemeralKeyOtherParty:(NSString *)ephemeralKeyOtherParty //both parts
{
    _ephemeralKeyOtherParty = [NSString stringWithString:ephemeralKeyOtherParty];
    string otherPartyPublicKey = [self.otherPartyPublicData[kPublicKey] defaultCString];
    string otherPartyEphemeralPublicKey = [self.ephemeralKeyOtherParty defaultCString];
    MAC->SetEphemeralPublicKeyAnotherParty(otherPartyEphemeralPublicKey, otherPartyPublicKey, self.isInitator);
}

- (NSString *)generateSessionKey
{
    if (self.isInitator == NO)
    {
        return [NSString stringWithDefaultCString:MAC->ShowSessionKey()];
    }
    else if ([self verifyMessage:self.encryptionKeyOtherParty])
    {
        return [NSString stringWithDefaultCString:MAC->ShowSessionKey()];
    }
    return nil;
}
#pragma mark - Getters and Setters
- (void)setOtherPartyPublicData:(NSDictionary *)otherPartyPublicData
{
    _otherPartyPublicData = [NSDictionary dictionaryWithDictionary:otherPartyPublicData];
}
- (NSString *)publicKey
{
    return [NSString stringWithDefaultCString:MAC->ShowPublicKey()];
}
- (NSString *)otherPartyPublicKey
{
    return [NSString stringWithDefaultCString:MAC->ShowOtherPartyPublicKey()];
}
- (NSString *)ephemeralPublicKey
{
    return [NSString stringWithDefaultCString:MAC->GetEphemeralPublicKey()];
}


@end
