//
//  Sigma.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 16.11.2013.
//
//

#ifndef __Cryptopp_for_iOS__Sigma__
#define __Cryptopp_for_iOS__Sigma__

/** \file
 */

#include "cryptlib.h"
#include "dsa.h"
#include <string>

using namespace std;
NAMESPACE_BEGIN(CryptoPP)

/// <a href="http://www.weidai.com/scan-mirror/ka.html#DH2">Unified Diffie-Hellman</a>
class Sigma : public AuthenticatedKeyAgreementDomain
{
public:
	Sigma(SimpleKeyAgreementDomain &domain)
    : d1(domain), d2(domain) {}
	Sigma(SimpleKeyAgreementDomain &staticDomain, SimpleKeyAgreementDomain &ephemeralDomain)
    : d1(staticDomain), d2(ephemeralDomain) {}
    
	CryptoParameters & AccessCryptoParameters() {return d1.AccessCryptoParameters();}
    
	unsigned int AgreedValueLength() const
    {return d1.AgreedValueLength() + d2.AgreedValueLength();}
    
	unsigned int StaticPrivateKeyLength() const
    {return d1.PrivateKeyLength();}
	unsigned int StaticPublicKeyLength() const
    {return d1.PublicKeyLength();}
	void GenerateStaticPrivateKey(RandomNumberGenerator &rng, byte *privateKey) const
    {d1.GeneratePrivateKey(rng, privateKey);}
	void GenerateStaticPublicKey(RandomNumberGenerator &rng, const byte *privateKey, byte *publicKey) const
    {d1.GeneratePublicKey(rng, privateKey, publicKey);}
	void GenerateStaticKeyPair(RandomNumberGenerator &rng, byte *privateKey, byte *publicKey) const
    {d1.GenerateKeyPair(rng, privateKey, publicKey);}
    
	unsigned int EphemeralPrivateKeyLength() const
    {return d2.PrivateKeyLength();}
	unsigned int EphemeralPublicKeyLength() const
    {return d2.PublicKeyLength();}
	void GenerateEphemeralPrivateKey(RandomNumberGenerator &rng, byte *privateKey) const
    {d2.GeneratePrivateKey(rng, privateKey);}
	void GenerateEphemeralPublicKey(RandomNumberGenerator &rng, const byte *privateKey, byte *publicKey) const
    {d2.GeneratePublicKey(rng, privateKey, publicKey);}
	void GenerateEphemeralKeyPair(RandomNumberGenerator &rng, byte *privateKey, byte *publicKey) const
    {d2.GenerateKeyPair(rng, privateKey, publicKey);}
    
    /* My additional Sigma features */
    void GenerateDSASignatureKeyPair(RandomNumberGenerator &rng, byte *privateKey, byte *publicKey);
    
    string GenerateSignature(SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte, DSA::PrivateKey signPrivateKey);
    bool VerifySignature(string signature, SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte, DSA::PublicKey signPublicKey);
    
    
	bool Agree(byte *agreedValue,
               const byte *staticPrivateKey, const byte *ephemeralPrivateKey,
               const byte *staticOtherPublicKey, const byte *ephemeralOtherPublicKey,
               bool validateStaticOtherPublicKey=true) const;
    
protected:
	SimpleKeyAgreementDomain &d1, &d2;
    string GenerateMessage(SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte);
    
};

NAMESPACE_END


#endif /* defined(__Cryptopp_for_iOS__Sigma__) */
