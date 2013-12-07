//
//  Hash.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 07.12.2013.
//
//

#ifndef __Cryptopp_for_iOS__Hash__
#define __Cryptopp_for_iOS__Hash__

#include <iostream>
#include "cryptopp/md5.h"
#include "cryptopp/sha.h"

////////////////////////////////////////////////////////////
class Hash{
public:
    static byte * getSHA1(const byte * input, int size);
    static int size;
};
////////////////////////////////////////////////////////////
#endif /* defined(__Cryptopp_for_iOS__Hash__) */
