//
//  SchnorrSignature.cpp
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 09.12.2013.
//
//

#include "SchnorrSignature.h"
#include "Hash.h"

#include "nbtheory.h"
using CryptoPP::ModularExponentiation;

#include "osrng.h"
using CryptoPP::AutoSeededRandomPool;

#include "dh.h"

#include "secblock.h"
using CryptoPP::SecByteBlock;

#include <sstream>

string const MagicNumber = "0xFF00FF00FF00FF00FF00FF00";

//***************************************************************
string SchnorrSign::IntegerToString(Integer i)
{
    ostringstream oss;
    oss << i;
    return oss.str();
}
//***************************************************************
Integer SchnorrSign::StringToInteger(string s)
{
    return Integer(s.c_str());
}
//***************************************************************
string SchnorrSign::SignatureToString(Signature signature)
{
    Integer r = signature.first;
    Integer s = signature.second;

    string rString = IntegerToString(r);
    string sString = IntegerToString(s);

    return rString + MagicNumber + sString;
}
//***************************************************************
Signature SchnorrSign::StringToSignature(string signature)
{
    int found = signature.find(MagicNumber);
    if (found != string::npos)
    {
        string rString = signature.substr(0, found);
        Integer r = StringToInteger(rString);
        string sString = signature.substr(found + MagicNumber.length());
        Integer s = StringToInteger(sString);
        return make_pair(r, s);
    }
    else
        return make_pair(Integer::Zero(), Integer::Zero());
}
//***************************************************************
Signature SchnorrSign::Sign(string message, Integer privateKey)
{
    AutoSeededRandomPool rng;
    Integer a = Integer(rng, Integer::Zero(), q);
    Integer r = a_exp_b_mod_c(g, a, p);
    Integer hash = Hash::getSHA1Integer(message, r);
    cout << "sign hash   " << hash << endl;
    Integer s = a + privateKey*hash;
    s %= q;
    return make_pair(r, s);
}
//***************************************************************
bool SchnorrSign::Verify(string message, Signature signature, Integer publicKey)
{
    Integer r = signature.first;
    Integer s = signature.second;
    Integer hash = Hash::getSHA1Integer(message, r);
    cout << "verify hash " << hash << endl;
    Integer gs = a_exp_b_mod_c(g, s, p);
    Integer ryh = r*a_exp_b_mod_c(publicKey, hash, p);
    ryh %= p;
    return (gs == ryh);
}
//***************************************************************
void SchnorrSign::test()
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
    
    DH dh;
    AutoSeededRandomPool rnd;
    
    dh.AccessGroupParameters().Initialize(p, q, g);
    SecByteBlock privKey(dh.PrivateKeyLength());
    SecByteBlock pubKey(dh.PublicKeyLength());
    dh.GenerateKeyPair(rnd, privKey, pubKey);
    
    Integer x, y;
    
    x.Decode(privKey.BytePtr(), privKey.SizeInBytes());
    //    cout << "Shared secret (A): " << std::hex << x << endl;
    
    y.Decode(pubKey.BytePtr(), pubKey.SizeInBytes());
    //    cout << "Shared secret (B): " << std::hex << y << endl;
    
    
    Integer gx = a_exp_b_mod_c(g, x, p);
    cout << "keys correct " << (gx == y) << endl;
    
    SchnorrSign schnorSign = SchnorrSign(p, q, g);
    string message = "hello";
    Signature signature = schnorSign.Sign(message, x);
    bool isValidSignature = schnorSign.Verify(message, signature, y);
    if (isValidSignature)
        cout << "Signature is valid" << endl;
    else
        cout << "Signature is invalid" << endl;
    
    string signatureString = SignatureToString(signature);
    Signature transformedSignature = StringToSignature(signatureString);
    isValidSignature = schnorSign.Verify(message, transformedSignature, y);
    if (isValidSignature)
        cout << "Signature is valid" << endl;
    else
        cout << "Signature is invalid" << endl;
    
}
