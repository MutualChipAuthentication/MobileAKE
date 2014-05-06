//
//  CryptoppSignature.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 27.10.2013.
//
//

#import "CryptoppSignature.h"
#include <iostream>
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


@implementation CryptoppSignature
@end
