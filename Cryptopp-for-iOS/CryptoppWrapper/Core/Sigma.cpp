//
//  Sigma.cpp
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 16.11.2013.
//
//

#include "pch.h"
#include "Sigma.h"

using CryptoPP::Exception;
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

#include "secblock.h"
using CryptoPP::SecByteBlock;

#include <hex.h>
using CryptoPP::HexEncoder;
#include <filters.h>
using CryptoPP::StringSink;
using CryptoPP::ArraySink;
using CryptoPP::StringSource;
using CryptoPP::StringStore;
using CryptoPP::Redirector;

using CryptoPP::SignerFilter;
using CryptoPP::SignatureVerificationFilter;


NAMESPACE_BEGIN(CryptoPP)
//********************************************************************************************************
void Sigma_TestInstantiations()
{
	Sigma dh(*(SimpleKeyAgreementDomain*)NULL);
}
//********************************************************************************************************
bool Sigma::Agree(byte *agreedValue,
                const byte *staticSecretKey, const byte *ephemeralSecretKey,
                const byte *staticOtherPublicKey, const byte *ephemeralOtherPublicKey,
                bool validateStaticOtherPublicKey) const
{
	return d1.Agree(agreedValue, staticSecretKey, staticOtherPublicKey, validateStaticOtherPublicKey)
    && d2.Agree(agreedValue+d1.AgreedValueLength(), ephemeralSecretKey, ephemeralOtherPublicKey, true);
}
void GenerateDSASignatureKeyPair(RandomNumberGenerator &rng, DSA::PrivateKey &PrivateKey, DSA::PublicKey &PublicKey)
{
    PrivateKey.GenerateRandomWithKeySize(rng, 1024);
    if (!PrivateKey.Validate(rng, 3))
    {
        throw("DSA key generation failed");
    }
    
    // Generate Public Key
    PublicKey.AssignFrom(PrivateKey);
}

//********************************************************************************************************
string Sigma::GenerateMessage(SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte)
{
    string message;
    HexEncoder hex(new StringSink(message));
    message = "0x";
    hex.Put(publicKeyA.BytePtr(), publicKeyA.SizeInBytes());
    hex.Put(publicKeyB.BytePtr(), publicKeyB.SizeInBytes());
    hex.Put(randomByte.BytePtr(), randomByte.SizeInBytes());
    hex.MessageEnd();
    return message;
}
//********************************************************************************************************
string Sigma::GenerateSignature(SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte, DSA::PrivateKey signPrivateKey)
{
    string message = GenerateMessage(publicKeyA, publicKeyB, randomByte);
    AutoSeededRandomPool rng;
    string signature;
    
    DSA::Signer signer( signPrivateKey );
    StringSource( message, true,
                 new SignerFilter( rng, signer,
                                  new StringSink( signature )
                                  ) // SignerFilter
                 );
    return signature;
}
//************************************di********************************************************************
bool Sigma::VerifySignature(string signature, SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte, DSA::PublicKey signPublicKey)
{
    string message = GenerateMessage(publicKeyA, publicKeyB, randomByte);
    DSA::Verifier verifier( signPublicKey );
    try {
        StringSource( message+signature, true,
                     new SignatureVerificationFilter(
                                                     verifier, NULL, SignatureVerificationFilter::THROW_EXCEPTION
                                                     /* SIGNATURE_AT_END */
                                                     )
                     );
        return true;

    }
    catch( CryptoPP::Exception& e )
    {
        return false;
    }

}
//********************************************************************************************************


NAMESPACE_END
