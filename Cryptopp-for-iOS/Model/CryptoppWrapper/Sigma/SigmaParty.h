//
//  SigmaParty.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import <Foundation/Foundation.h>
#include <string>

#include "cryptopp/rsa.h"
#include "cryptopp/osrng.h"
#include "cryptopp/integer.h"
#include "cryptopp/sha.h"
#include "cryptopp/hex.h"
#include "cryptopp/filters.h"

#include <iostream>
using std::cout;
using std::cerr;
using std::endl;

#include <string>
using std::string;

#include <stdexcept>
using std::runtime_error;

#include "osrng.h"
using CryptoPP::AutoSeededRandomPool;

#include "integer.h"
using CryptoPP::Integer;

#include "nbtheory.h"
using CryptoPP::ModularExponentiation;

#include "dh.h"
using CryptoPP::DH;

#include "dh2.h"
using CryptoPP::DH2;


#include "secblock.h"
using CryptoPP::SecByteBlock;

typedef int Signature;
typedef int ID;
typedef int MAC;
typedef int KEY;

@interface SigmaParty : NSObject
- (KEY)generateKeys;  //s, g^x
- (ID)generateID:(int) partyID;
- (Signature)sign:(KEY)secretKey;
- (MAC)generateMAC:(ID)partyID key:(KEY)key;
- (BOOL)verifyMac:(MAC)mac;
- (BOOL)verifySignature:(Signature)signature;
- (void)initiateProtocol:(SigmaParty *)party;  //sends s, g^x
- (void)sendSigmaParty:(SigmaParty *)party key:(KEY)key signature:(Signature)signature identity:(ID)identity mac:(MAC)mac;
- (void)verifyMessageFromParty:(SigmaParty *)party key:(KEY)key signature:(Signature)signature identity:(ID)identity mac:(MAC)mac;


@end
