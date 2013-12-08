//
//  DiffieHellmanKey.cpp
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 07.12.2013.
//
//

#include "KeyGenerator.h"
#include "Hash.h"


#include "secblock.h"
using CryptoPP::SecByteBlock;

void KeyGenerator::GenerateEphemeralKeyPair(CryptoPP::RandomNumberGenerator &rng, byte *privateKey, byte *publicKey) const
{
    Integer a = Integer(rng, keySize);
    cout << "random a " << a << endl;
    byte *aEncoded;
    a.Encode(aEncoded, keySize);
    privateKey = Hash::getSHA1(aEncoded, keySize);
    CryptoPP::Integer exponent(privateKey, keySize);
    CryptoPP::Integer cA = a_exp_b_mod_c(g, exponent, p);   //ca = g^H(a)
    cA.Encode(publicKey, keySize);
}


// K_i = H(K, i)
byte * KeyGenerator::GenerateKeyFromHashedKey(byte *key, int random)
{
    Integer k = CryptoPP::Integer(key, keySize);
    k += CryptoPP::Integer(random);
    byte *encoded;
    k.Encode(encoded, keySize);
    return Hash::getSHA1(encoded, keySize);
}


//cb^exp
byte * KeyGenerator::EstablishSessionKey(byte *ephemeralPrivateKey, byte * ephemeralPublicKey)
{
    CryptoPP::Integer cb = CryptoPP::Integer(ephemeralPrivateKey, keySize);
    CryptoPP::Integer exp = CryptoPP::Integer(ephemeralPublicKey, keySize);
    CryptoPP::Integer key = a_exp_b_mod_c(cb, exp, p);
    byte *sessionKey;
    key.Encode(sessionKey, keySize);
    return sessionKey;
}
