//
//  SigmaKeyAgreement.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import "SigmaKeyAgreement.h"
#import "NSString+CStringLossless.h"
#import "NSData+Base64.h"
#include "Sigma.h"



#include "osrng.h"
using CryptoPP::AutoSeededRandomPool;

#include "dh.h"


@interface SigmaKeyAgreement ()
{
    SecByteBlock publicKey;
    SecByteBlock privateKey;
    SecByteBlock publicKeyB;
    
    DSA::PublicKey signPubKey;
    DSA::PrivateKey signPrivKey;
    Sigma sigma;
}
@end

@implementation SigmaKeyAgreement
- (id)init
{
    self = [super init];
    if (self)
    {
        DH dh;
        AutoSeededRandomPool rnd;
        sigma = Sigma();
        
        dh.AccessGroupParameters().Initialize(sigma.getP(), sigma.getQ(), sigma.getG());
        SecByteBlock privKey(dh.PrivateKeyLength());
        SecByteBlock pubKey(dh.PublicKeyLength());
        dh.GenerateKeyPair(rnd, privKey, pubKey);
        publicKey = pubKey;
        privateKey = privKey;
        sigma.GenerateDSASignatureKeyPair(rnd, signPrivKey, signPubKey);
    }
    return self;
}
- (NSValue *)generateInitialMessage
{
    InitialMessage message = sigma.GenerateInitialMessage(publicKey);
    string stringMessage = Sigma::InitialMessageToString(message);
    return [NSValue valueWithPointer:new string(stringMessage)];
//    string *pointer = new string(stringMessage);
//    void *sVoid = static_cast<void*>(pointer);
//    cout << "string message " << stringMessage << endl;
//    return [NSData dataWithBytes:sVoid length:sizeof(*sVoid)];
}
- (NSValue *)generateResponse:(NSValue *)message
{
    string stringMessage = *((string *)[message pointerValue]);
    cout << "string message " << stringMessage << endl;
    InitialMessage initialMessage = Sigma::stringToInitialMesssage(stringMessage);
    Response response = sigma.GenerateResponse(initialMessage, publicKey, signPrivKey);
    
    BOOL verifyResponse = sigma.VerifyResponse(initialMessage, response, signPubKey);
    if (!verifyResponse)
        cout << "response failed" << endl;
    
    publicKeyB = response.first;
    string responseString = Sigma::ResponseToString(response);
    void *sVoid = static_cast<void*>(&responseString);
    cout << "response string " << responseString << endl;
    return [NSValue valueWithPointer:new string(responseString)];
}

- (NSValue *)dsaPubKey
{
    string dsaPubKey = sigma.DSAPubKeyToString(signPubKey);
//    cout << dsaPubKey << endl;
    void *sVoid = static_cast<void*>(&dsaPubKey);
    
    NSData *value = [NSData dataWithBytes:sVoid length:dsaPubKey.length()];
    return [NSValue valueWithPointer:new string(dsaPubKey)];
    
//    NSString *nsstring2 = [NSString stringFromCStringLossless:value];
//    value = [nsstring2 cstringFromLosslessString];
//    string s =  string(*(static_cast<std::string*>([value pointerValue])));
//    if (dsaPubKey.compare(s))
//        cout << "dsa failed " << endl;
//    
//    void *sVoid = static_cast<void*>(&dsaPubKey);
//    
//    
//    NSData *data = [NSData dataWithBytes:sVoid length:dsaPubKey.length()];
//    NSString *nsstring = [data base64Encoding];
//    
//    data = [NSData dataFromBase64String:nsstring];
//    string &testString = *((string *)[data bytes]);
//    
//    if (!testString.compare(dsaPubKey))
//        cout << "dsa ok " << endl;
//    else
//        cout << "dsa failed " << endl;
//    cout << "dsa pub key " << dsaPubKey << endl;
//    return nsstring;
}

- (BOOL)verifyResponse:(NSValue *)responseEncoded message:(NSValue *)messageEncoded signPubKey:(NSValue *)dsaPubKeyEncoded
{
    string stringMessage = *((string *)[messageEncoded pointerValue]);
    string dsaPubKeyEncodedString = *((string *)[dsaPubKeyEncoded pointerValue]);
    string responseString = *((string *)[responseEncoded pointerValue]);
//    cout << "message " << stringMessage << endl;
//    cout << "response string " << responseString << endl;
    InitialMessage initialMessage = Sigma::stringToInitialMesssage(stringMessage);
    Response responseMessage = Sigma::stringToResponse(responseString);
    publicKeyB = responseMessage.first;
    
    DSA::PublicKey signPubKeyB = Sigma::stringToDSAPubKey(dsaPubKeyEncodedString);
    return sigma.VerifyResponse(initialMessage, responseMessage, signPubKeyB);
}

- (NSValue *)generateSessionSignature:(NSValue *)messageEncoded andResponse:(NSValue *)responseEncoded
{
    string responseString =  *((string *)[responseEncoded pointerValue]);
    string stringMessage = *((string *)[messageEncoded pointerValue]);
  
    InitialMessage initialMessage = Sigma::stringToInitialMesssage(stringMessage);
    Response response = Sigma::stringToResponse(responseString);
    
    SessionSignature sessionSignature = sigma.GenerateSessionSignature(initialMessage, response.first, signPrivKey);
    
    Integer sessionKeyA = sigma.GenerateSessionKey(publicKeyB, privateKey);
    cout << "established session key " << sessionKeyA << endl;
    void *sVoid = static_cast<void*>(&sessionSignature);
    return [NSValue valueWithPointer:new string(sessionSignature)];
}


- (BOOL)verifySessionSignature:(NSValue *)sessionSignature message:(NSValue *)messageEncoded andResponse:(NSValue *)responseEncoded signPubKey:(NSValue *)dsaPubKeyEncoded

{
    string stringMessage = *((string *)[messageEncoded pointerValue]);
    string dsaPubKeyEncodedString = *((string *)[dsaPubKeyEncoded pointerValue]);
    string responseString =  *((string *)[responseEncoded pointerValue]);
    
    InitialMessage initialMessage = Sigma::stringToInitialMesssage(stringMessage);
    Response response = Sigma::stringToResponse(responseString);
    DSA::PublicKey signPubKeyB = Sigma::stringToDSAPubKey(dsaPubKeyEncodedString);
    
    Integer sessionKeyA = sigma.GenerateSessionKey(publicKeyB, privateKey);
    cout << "established session key " << sessionKeyA << endl;
    
    
    SessionSignature signature = *((string *)[sessionSignature pointerValue]);
    return sigma.VerifySessionSignature(signature, initialMessage, response.first, signPubKeyB);
}

+ (void)simulateProtocol
{
    NSLog(@"test ");
    SigmaKeyAgreement *partyA = [[SigmaKeyAgreement alloc] init];
    SigmaKeyAgreement *partyB = [[SigmaKeyAgreement alloc] init];
    
    
    NSValue *initialMessage = [partyA generateInitialMessage];
    NSValue *response = [partyB generateResponse:initialMessage];
    NSValue *signKey = [partyB dsaPubKey];
    BOOL verifyResponse  = [partyA verifyResponse:response message:initialMessage signPubKey:signKey];
    if (!verifyResponse)
    {
        NSLog(@"party B response incorrect, aborting!");
        return;
    }
    NSValue *sessionSignature = [partyA generateSessionSignature:initialMessage andResponse:response];
    signKey = [partyA dsaPubKey];
    verifyResponse = [partyB verifySessionSignature:sessionSignature message:initialMessage andResponse:response signPubKey:signKey];
    if (!verifyResponse)
    {
        NSLog(@"party A response incorrect, aborting!");
        return;
    }
    NSLog(@"all went fine");
}



@end
