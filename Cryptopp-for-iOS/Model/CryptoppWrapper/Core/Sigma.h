//
//  Sigma.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 16.11.2013.
//
//

#ifndef __Cryptopp_for_iOS__Sigma__
#define __Cryptopp_for_iOS__Sigma__

#include <iostream>
#include <string>
#include "integer.h"

#include "cryptlib.h"

#include "dsa.h"
#include "secblock.h"

using namespace std;
using namespace CryptoPP;

typedef pair<SecByteBlock, SecByteBlock> InitialMessage;
typedef pair<SecByteBlock, string> Response;
typedef string SessionSignature;

////////////////////////////////////////////////////////////
class Sigma
{
private:
    Integer p, q, g;
    static Integer decodeSecByteBlock(SecByteBlock key);
    static SecByteBlock encodeSecByteBlock(Integer key);


public:
    Sigma()
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
        this->p = p;
        this->q = q;
        this->g = g;
    }
    
    Integer getP() { return p; }
    Integer getQ() { return q; }
    Integer getG() { return g; }

	Sigma(Integer p, Integer q, Integer g)
    : p(p), q(q), g(g) {}
    /* My additional Sigma features */
    void GenerateDSASignatureKeyPair(RandomNumberGenerator &rng, DSA::PrivateKey &PrivateKey, DSA::PublicKey &PublicKey);
    
    InitialMessage GenerateInitialMessage(SecByteBlock publicKeyA);   //s, g^x
    Response GenerateResponse(InitialMessage message, SecByteBlock publicKeyB, DSA::PrivateKey signPrivateKey);  //g^y, sign_SK_b(g^x, g^y, s)
    bool VerifyResponse(InitialMessage message, Response response, DSA::PublicKey signPublicKey);
    // ver(sign_sk_b(g^x, g^y, s), pk_b) == true
    SessionSignature GenerateSessionSignature(InitialMessage message, SecByteBlock publicKeyB, DSA::PrivateKey signPrivateKey);
    bool VerifySessionSignature(SessionSignature signature, InitialMessage message, SecByteBlock publicKeyB, DSA::PublicKey signPublicKey);
    
    
    Integer GenerateSessionKey(SecByteBlock publicKeyA, SecByteBlock privateKeyB);
    
    
    string GenerateSignature(SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte, DSA::PrivateKey signPrivateKey);
    bool VerifySignature(string signature, SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte, DSA::PublicKey signPublicKey);
    static string InitialMessageToString(InitialMessage message);
    static InitialMessage stringToInitialMesssage(string message);
    static string ResponseToString(Response response);
    static Response stringToResponse(string response);
    static string DSAPubKeyToString(DSA::PublicKey dsaPubKey);
    static DSA::PublicKey stringToDSAPubKey(string stringKey);
    static void test();
    
protected:
    string GenerateMessage(SecByteBlock publicKeyA, SecByteBlock publicKeyB, SecByteBlock randomByte);
    
};
////////////////////////////////////////////////////////////

#endif /* defined(__Cryptopp_for_iOS__Sigma__) */
