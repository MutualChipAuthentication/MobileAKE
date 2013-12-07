//
//  DiffieHellmanKey.cpp
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 07.12.2013.
//
//

#include "KeyGenerator.h"
#include "Hash.h"

void KeyGenerator::GenerateEphemeralKeyPair(CryptoPP::RandomNumberGenerator &rng, byte *privateKey, byte *publicKey) const
{
    const int size = Hash::size;
    Integer a = Integer(rng, size);
    byte *aEncoded;
    a.Encode(aEncoded, size);
    privateKey = Hash::getSHA1(aEncoded, size);
    CryptoPP::Integer exponent(privateKey, size);
    CryptoPP::Integer cA = a_exp_b_mod_c(g, exponent, p);   //ca = g^H(a)
    cA.Encode(publicKey, size);
}


// K_i = H(K, i)
byte * KeyGenerator::GenerateKeyFromHashedKey(byte *key, int random)
{
    const int size = Hash::size;
    Integer k = CryptoPP::Integer(key, size);
    k += CryptoPP::Integer(random);
    byte *encoded;
    k.Encode(encoded, size);
    return Hash::getSHA1(encoded, size);
}


//cb^exp
byte * KeyGenerator::EstablishSessionKey(byte *ephemeralPrivateKey, byte * ephemeralPublicKey)
{
    const int size = Hash::size;
    CryptoPP::Integer cb = CryptoPP::Integer(ephemeralPrivateKey, size);
    CryptoPP::Integer exp = CryptoPP::Integer(ephemeralPublicKey, size);
    CryptoPP::Integer key = a_exp_b_mod_c(cb, exp, p);
    byte *sessionKey;
    key.Encode(sessionKey, size);
    return sessionKey;
}
