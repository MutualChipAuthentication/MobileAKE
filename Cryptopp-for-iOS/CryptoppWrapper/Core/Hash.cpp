//
//  Hash.cpp
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 07.12.2013.
//
//

#include "Hash.h"
using namespace std;
int Hash::size = CryptoPP::SHA1::DIGESTSIZE;
//***************************************************************
byte * Hash::getSHA1(const byte * input, int length)
{
    CryptoPP::SHA1 sha;
    byte *digest = new byte [CryptoPP::SHA1::DIGESTSIZE];
    sha.CalculateDigest(digest, input, length);
    return digest;
}
void Hash::printStringAsHex(byte *m, int length)
{
    for (int i = 0; i < length; i++) {
        cout << hex << (int)m[i] << " ";
    }
}
//***************************************************************
Integer Hash::getSHA1Integer(string m, Integer r)
{
    byte *encodedMessage = (byte *)m.c_str();
    int messageSize = m.length();
    int rSize = r.MinEncodedSize();
    byte encodedR[rSize];
    r.Encode(encodedR, rSize);
    
    byte hashInput[rSize + messageSize];
    copy(encodedMessage, encodedMessage + messageSize, hashInput);
    copy(encodedR, encodedR + rSize, hashInput + messageSize);
    byte *hashOutput = getSHA1(hashInput, rSize+messageSize);
    Integer result;
    r.Decode(hashOutput, Hash::size);
    return r;
}
