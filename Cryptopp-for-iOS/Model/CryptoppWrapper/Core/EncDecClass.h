#pragma once
#include <utility>
#include "osrng.h"
#include <string>
#include <sstream>
using CryptoPP::AutoSeededRandomPool;

#include <iostream>
using std::cout;
using std::cerr;
using std::endl;

#include <string>
using std::string;

#include <cstdlib>
using std::exit;

#include "cryptlib.h"
using CryptoPP::Exception;

#include "hex.h"
using CryptoPP::HexEncoder;
using CryptoPP::HexDecoder;

#include "filters.h"
using CryptoPP::StringSink;
using CryptoPP::StringSource;
using CryptoPP::StreamTransformationFilter;

#include "aes.h"
using CryptoPP::AES;

#include "ccm.h"
using CryptoPP::CTR_Mode;

#include "assert.h"

class EncDecClass
{
private:
	byte * encryption_key;
public:
	EncDecClass(void);
	~EncDecClass(void);
	
	string encryptCert(unsigned char*,int, byte*, int, byte*, int,byte*, int);
	//std::pair<std::pair<unsigned char*, int>,std::pair<byte *, int> > decryptCert(string decryption, byte*, int,byte*, int);
	std::pair<std::vector<unsigned char>, std::vector<byte> > decryptCert(string decryption, byte*, int,byte*, int);
	void setKey(byte key[], int size);
};

