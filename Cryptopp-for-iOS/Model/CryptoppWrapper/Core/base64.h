//
//  base64.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 31/05/14.
//
//

#ifndef Cryptopp_for_iOS_base64_h
#define Cryptopp_for_iOS_base64_h
#include <string>
std::string base64_encode(unsigned char const* , unsigned int len);
std::string base64_decode(std::string const& s);
#endif
