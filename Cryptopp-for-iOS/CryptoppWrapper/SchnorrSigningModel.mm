//
//  SchnorrSigningModel.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 10.12.2013.
//
//

#import "SchnorrSigningModel.h"

#include "osrng.h"
using CryptoPP::AutoSeededRandomPool;

#include "dh.h"

using namespace std;

NSString *const kSignature = @"signature";
NSString *const kMessage = @"message";
NSString *const kPublicKey = @"publicKey";

@interface SchnorrSigningModel ()
{
    Integer publicKey;
    Integer privateKey;
    SchnorrSign schnorr;
}
@end

@implementation SchnorrSigningModel
- (id)init
{
    self = [super init];
    if (self)
    {
        schnorr = SchnorrSign();
        DH dh;
        AutoSeededRandomPool rnd;
        
        dh.AccessGroupParameters().Initialize(schnorr.getP(), schnorr.getQ(), schnorr.getG());
        SecByteBlock privKey(dh.PrivateKeyLength());
        SecByteBlock pubKey(dh.PublicKeyLength());
        dh.GenerateKeyPair(rnd, privKey, pubKey);
        
        privateKey.Decode(privKey.BytePtr(), privKey.SizeInBytes());
        publicKey.Decode(pubKey.BytePtr(), pubKey.SizeInBytes());
    }
    return self;
}

- (NSDictionary *)createSignatureForMessage:(NSString *)message
{
    string stringMessage = [message cStringUsingEncoding:NSASCIIStringEncoding];
    Signature signature = schnorr.Sign(stringMessage, privateKey);
    string stringSignature = SchnorrSign::SignatureToString(signature);
    NSString *nsstringSignature = [[NSString alloc] initWithCString:stringSignature.c_str() encoding:NSASCIIStringEncoding];
    NSString *publicKeyString = [SchnorrSigningModel IntegerToString:publicKey];
    return @{kSignature: nsstringSignature, kMessage: message, kPublicKey: publicKeyString};
}


+ (NSString *)IntegerToString:(Integer)i
{
    string iString = SchnorrSign::IntegerToString(i);
    return [[NSString alloc] initWithCString:iString.c_str() encoding:NSASCIIStringEncoding];
}


+ (BOOL)verifySignature:(NSString *)signature ofMessage:(NSString *)message withPubKey:(NSString *)publicKey
{
    SchnorrSign schnorSign = SchnorrSign();
    string messageToVerify = string([message cStringUsingEncoding:NSASCIIStringEncoding]);
    string signatureString = string([signature cStringUsingEncoding:NSASCIIStringEncoding]);
    string pubKeyString = string([publicKey cStringUsingEncoding:NSASCIIStringEncoding]);
    
    Signature signatureToVerify = SchnorrSign::StringToSignature(signatureString);
    Integer pubKey = SchnorrSign::StringToInteger(pubKeyString);
    
    bool isValidSignature = schnorSign.Verify(messageToVerify, signatureToVerify, pubKey);
    if (isValidSignature)
    {
        cout << "Signature is valid" << endl;
        return YES;
    }
    else
    {
        cout << "Signature is invalid" << endl;
        return NO;
    }
}

- (void)test
{
    NSString *message = @"hello";
    NSDictionary *signature = [self createSignatureForMessage:message];
    BOOL validate = [SchnorrSigningModel verifySignature:signature[kSignature] ofMessage:message withPubKey:signature[kPublicKey]];
    NSLog(@"verify schnorr signing model %d", validate);
}

@end
