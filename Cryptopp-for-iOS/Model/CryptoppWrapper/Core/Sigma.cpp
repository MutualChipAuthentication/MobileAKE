//
//  Sigma.cpp
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 16.11.2013.
//
//

#include "Sigma.h"
#include "HashClass.h"
#include "SchnorrSignature.h"

using CryptoPP::Exception;
using std::string;

#include <stdexcept>
using std::runtime_error;

#include "osrng.h"
using CryptoPP::AutoSeededRandomPool;

#include "nbtheory.h"
using CryptoPP::ModularExponentiation;

#include "dh.h"
using CryptoPP::DH;


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


string const MagicNumber = "0xFF00FF00FF00FF00FF00FF00";

//********************************************************************************************************
Integer Sigma::decodeSecByteBlock(SecByteBlock key)
{
    Integer x;
    x.Decode(key.BytePtr(), key.SizeInBytes());
    return x;
}
//********************************************************************************************************
SecByteBlock Sigma::encodeSecByteBlock(Integer key)
{
    int length = key.MinEncodedSize();
    byte byteX [length];
    key.Encode(byteX, length);
    
    SecByteBlock pubKeyA;
    pubKeyA.Assign(byteX, length);
    
    //check
    if (key != decodeSecByteBlock(pubKeyA))
        cout << "Error while encoding Integer to SecByteBlock" << endl;
    
    return pubKeyA;
}
//********************************************************************************************************
string Sigma::InitialMessageToString(InitialMessage message)
{
    Integer s = decodeSecByteBlock(message.first);
    Integer x = decodeSecByteBlock(message.second);
    
    return SchnorrSign::SignatureToString(make_pair(s, x));
}
//********************************************************************************************************
InitialMessage Sigma::stringToInitialMesssage(string message)
{
    Signature signature = SchnorrSign::StringToSignature(message);
    return make_pair(encodeSecByteBlock(signature.first), encodeSecByteBlock(signature.second));
}
//********************************************************************************************************
string Sigma::ResponseToString(Response response)
{
    Integer y = decodeSecByteBlock(response.first);
    string s = response.second;
    string yString = SchnorrSign::IntegerToString(y);
    return yString + MagicNumber + s;
}
//********************************************************************************************************
Response Sigma::stringToResponse(string response)
{
    int found = response.find(MagicNumber);
    if (found != string::npos)
    {
        string yString = response.substr(0, found);
        Integer y = SchnorrSign::StringToInteger(yString);
        string signature = response.substr(found + MagicNumber.length());
        return make_pair(encodeSecByteBlock(y), signature);
    }
    else
        return make_pair(encodeSecByteBlock(Integer::Zero()), "");
}
//********************************************************************************************************
InitialMessage Sigma::GenerateInitialMessage(SecByteBlock publicKeyA) //s, g^x
{
    Integer x = decodeSecByteBlock(publicKeyA);
    AutoSeededRandomPool rng;
    Integer s = Integer(rng, Integer::Zero(), q);
    return make_pair(encodeSecByteBlock(s), encodeSecByteBlock(x));
}
//********************************************************************************************************
Response Sigma::GenerateResponse(InitialMessage message, SecByteBlock publicKeyB, DSA::PrivateKey signPrivateKey)  //g^y, sign_SK_b(g^x, g^y, s)
{
    string signature = GenerateSignature(message.second, publicKeyB, message.first, signPrivateKey);
    
    return make_pair(publicKeyB, signature);
}
//********************************************************************************************************
string Sigma::DSAPubKeyToString(DSA::PublicKey dsaPubKey)
{
    std::string encodedDsaPublicKey;
	dsaPubKey.DEREncode(StringSink(encodedDsaPublicKey).Ref());
    //test
    DSA::PublicKey dPK = stringToDSAPubKey(encodedDsaPublicKey);
    std::string encodedDsaPublicKey2;
	dPK.DEREncode(StringSink(encodedDsaPublicKey2).Ref());
    
    if (!encodedDsaPublicKey.compare(encodedDsaPublicKey2))
        cout << "convertsion of pub sign key ok" << endl;
    else
        cout << "sth went wrong" << endl;

    return encodedDsaPublicKey;
}
//********************************************************************************************************
DSA::PublicKey Sigma::stringToDSAPubKey(string stringKey)
{
    DSA::PublicKey decodedDsaPublicKey;
	decodedDsaPublicKey.BERDecode(StringStore(stringKey).Ref());
    return decodedDsaPublicKey;
}
//********************************************************************************************************
bool Sigma::VerifyResponse(InitialMessage message, Response response, DSA::PublicKey signPublicKey)
{
    return VerifySignature(response.second, message.second, response.first, message.first, signPublicKey);
}
// ver(sign_sk_b(g^x, g^y, s), pk_b) == true
//********************************************************************************************************
SessionSignature Sigma::GenerateSessionSignature(InitialMessage message, SecByteBlock publicKeyB, DSA::PrivateKey signPrivateKey)
{
    return GenerateSignature(message.second, publicKeyB, message.first, signPrivateKey);
}
//********************************************************************************************************
bool Sigma::VerifySessionSignature(SessionSignature signature, InitialMessage message, SecByteBlock publicKeyB, DSA::PublicKey signPublicKey)
{
    return VerifySignature(signature, message.second, publicKeyB, message.first, signPublicKey);
}
//********************************************************************************************************
Integer Sigma::GenerateSessionKey(SecByteBlock publicKeyA, SecByteBlock privateKeyB)
{
    Integer gx, y, gxy;
    gx.Decode(publicKeyA.BytePtr(), publicKeyA.SizeInBytes());
    y.Decode(privateKeyB.BytePtr(), privateKeyB.SizeInBytes());
    gxy = a_exp_b_mod_c(gx, y, p);
    return HashClass::getSHA1Integer("", gxy);
}
//********************************************************************************************************
void Sigma::GenerateDSASignatureKeyPair(RandomNumberGenerator &rng, DSA::PrivateKey &PrivateKey, DSA::PublicKey &PublicKey)
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
void Sigma::test()
{
    Integer p("0xB10B8F96A080E01DDE92DE5EAE5D54EC52C99FBCFB06A3C6"
              "9A6A9DCA52D23B616073E28675A23D189838EF1E2EE652C0"
              "13ECB4AEA906112324975C3CD49B83BFACCBDD7D90C4BD70"
              "98488E9C219A73724EFFD6FAE5644738FAA31A4FF55BCCC0"
              "A151AF5F0DC8B4BD45BF37DF365C1A65E68CFDA76D4DA708"
              "DF1FB2BC2E4A4371");
    
    Integer g("0xA4D1CBD5C3FD34126765A442EFB99905F8104DD258AC507F"
              "D6406CFF14266D31266FEA1E5C41564B777E690F5504F213"
              "160217B4B01B886A5E91547F9E2749F4D7FBD7D3B9A92EE1"
              "909D0D2263F80A76A6A24C087A091F531DBF0A0169B6A28A"
              "D662A4D18E73AFA32D779D5918D08BC8858F4DCEF97C2A24"
              "855E6EEB22B3B2E5");
    
    Integer q("0xF518AA8781A8DF278ABA4E7D64B7CB9D49462353");
    
    // Schnorr Group primes are of the form p = rq + 1, p and q prime. They
    // provide a subgroup order. In the case of 1024-bit MODP Group, the
    // security level is 80 bits (based on the 160-bit prime order subgroup).
    
    // For a compare/contrast of using the maximum security level, see
    // dh-unified.zip. Also see http://www.cryptopp.com/wiki/Diffie-Hellman
    // and http://www.cryptopp.com/wiki/Security_level .
    
    DH dhA, dhB;
    AutoSeededRandomPool rnd;
    
    dhA.AccessGroupParameters().Initialize(p, q, g);
    SecByteBlock privKeyA(dhA.PrivateKeyLength());
    SecByteBlock pubKeyA(dhA.PublicKeyLength());
    dhA.GenerateKeyPair(rnd, privKeyA, pubKeyA);
    
    dhB.AccessGroupParameters().Initialize(p, q, g);
    SecByteBlock privKeyB(dhB.PrivateKeyLength());
    SecByteBlock pubKeyB(dhB.PublicKeyLength());
    dhB.GenerateKeyPair(rnd, privKeyB, pubKeyB);
    
    Sigma sigma = Sigma(p, q, g);
    
    DSA::PublicKey signPubKeyA, signPubKeyB;
    DSA::PrivateKey signPrivKeyA, signPrivKeyB;
    
    sigma.GenerateDSASignatureKeyPair(rnd, signPrivKeyA, signPubKeyA);
    sigma.GenerateDSASignatureKeyPair(rnd, signPrivKeyB, signPubKeyB);
    
    InitialMessage message = sigma.GenerateInitialMessage(pubKeyA);
    
    message = sigma.stringToInitialMesssage(sigma.InitialMessageToString(message));
    
    Response response = sigma.GenerateResponse(message, pubKeyB, signPrivKeyB);
    response = sigma.stringToResponse(sigma.ResponseToString(response));

    bool verifyResponse = sigma.VerifyResponse(message, response, signPubKeyB);
    if (!verifyResponse)
        cout << "Signature of B is invalid" << endl;
    else
        cout << "Signature of B is valid" << endl;
    
    SessionSignature sessionSignature = sigma.GenerateSessionSignature(message, pubKeyB, signPrivKeyA);
    bool verifySignature = sigma.VerifySessionSignature(sessionSignature, message, pubKeyB, signPubKeyA);
    if (!verifySignature)
        cout << "Signature of A is invalid" << endl;
    else
        cout << "Signature of A is valid" << endl;
    
    Integer sessionKeyA = sigma.GenerateSessionKey(pubKeyB, privKeyA);
    Integer sessionKeyB = sigma.GenerateSessionKey(pubKeyA, privKeyB);
    if (sessionKeyA != sessionKeyB)
        cout << "Session keys are different" << endl;
    else
        cout << "Keys established" << endl;
}
