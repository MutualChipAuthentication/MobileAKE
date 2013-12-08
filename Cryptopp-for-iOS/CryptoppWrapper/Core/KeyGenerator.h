//
//  DiffieHellmanKey.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 07.12.2013.
//
//

#ifndef __Cryptopp_for_iOS__DiffieHellmanKey__
#define __Cryptopp_for_iOS__DiffieHellmanKey__

#include <iostream>
#include "cryptlib.h"
#include "dsa.h"
#include <string>
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
using CryptoPP::RandomNumberGenerator;
#include "Hash.h"

using namespace std;
//NAMESPACE_BEGIN(CryptoPP)

////////////////////////////////////////////////////////////
class KeyGenerator
{
public:
    int keySize;
    KeyGenerator(DH &domain)
    : dh(domain) {
        p = dh.GetGroupParameters().GetModulus();
		q = dh.GetGroupParameters().GetSubgroupOrder();
		g = dh.GetGroupParameters().GetGenerator();
        keySize = Hash::size;
    }

    
    unsigned int StaticPrivateKeyLength() const
    {return dh.PrivateKeyLength();}
	unsigned int StaticPublicKeyLength() const
    {return dh.PublicKeyLength();}
	void GenerateStaticPrivateKey(RandomNumberGenerator &rng, byte *privateKey) const
    {dh.GeneratePrivateKey(rng, privateKey);}
	void GenerateStaticPublicKey(RandomNumberGenerator &rng, const byte *privateKey, byte *publicKey) const
    {dh.GeneratePublicKey(rng, privateKey, publicKey);}
	void GenerateStaticKeyPair(RandomNumberGenerator &rng, byte *privateKey, byte *publicKey) const //x, g^x
    {dh.GenerateKeyPair(rng, privateKey, publicKey);}
    
	unsigned int EphemeralPrivateKeyLength() const { return keySize; }
	void GenerateEphemeralPrivateKey(RandomNumberGenerator &rng, byte *privateKey) const; //cb^ha
	unsigned int EphemeralPublicKeyLength() const { return keySize; }
	void GenerateEphemeralPublicKey(RandomNumberGenerator &rng, byte *privateKey) const; //cb^ha
    void GenerateEphemeralKeyPair(RandomNumberGenerator &rng, byte *privateKey, byte *publicKey) const;

    byte * GenerateKeyFromHashedKey(byte *key, int random);
    byte * EstablishSessionKey(byte *ephemeralPrivateKey, byte * ephemeralPublicKey);

protected:
	DH &dh;
    Integer p, q, g;
    
};
////////////////////////////////////////////////////////////
#endif /* defined(__Cryptopp_for_iOS__DiffieHellmanKey__) */
