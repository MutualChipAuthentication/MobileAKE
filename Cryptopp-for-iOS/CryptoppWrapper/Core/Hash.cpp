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
    byte * digest = new byte [ size ];
    cout << size << endl;
    sha.CalculateDigest(digest, (const byte*)input, length);
    cout << digest << endl;
    return digest;
}
//***************************************************************
