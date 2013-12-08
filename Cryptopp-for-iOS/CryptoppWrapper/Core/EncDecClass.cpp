#include "EncDecClass.h"


EncDecClass::EncDecClass(void)
{
}


EncDecClass::~EncDecClass(void)
{
}


void EncDecClass::setKey(byte key[], int size){
	encryption_key = new byte[size];
}

string EncDecClass::encryptCert(unsigned char *cert,int cert_size, byte *r, int r_size, byte * key, int key_size, byte * iv, int iv_size){
	const byte separator[] = {0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00};
	unsigned char * lc_cert = new unsigned char[cert_size];
	lc_cert = cert;
	unsigned char * lc_r = new unsigned char[r_size];
	lc_r = r;

	string str_cert_plus_r;

	HexEncoder encoder;
	encoder.Put(lc_cert, cert_size);
	encoder.Put(separator, sizeof(separator));
	encoder.Put(r, r_size);
	encoder.MessageEnd();

	int size = encoder.MaxRetrievable();
	if(size)
	{
		str_cert_plus_r.resize(size);		
		encoder.Get((byte*)str_cert_plus_r.data(), str_cert_plus_r.size());
	}

	string cipher, encoded;

	try
	{
		cout << "str_cert_plus_r text: " << endl;
		cout << str_cert_plus_r << endl;
		//CTR_Mode< AES >::Encryption e;
		//e.SetKeyWithIV(encryption_key, sizeof(encryption_key), iv);
		CTR_Mode< AES >::Encryption e;
		e.SetKeyWithIV(key, key_size, iv);


		// The StreamTransformationFilter adds padding
		//  as required. ECB and CBC Mode must be padded
		//  to the block size of the cipher.
		StringSource(str_cert_plus_r, true, 
			new StreamTransformationFilter(e,
				new StringSink(cipher)
			) // StreamTransformationFilter      
		); // StringSource
	}
	catch(const CryptoPP::Exception& e)
	{
		cerr << e.what() << endl;
	}

	// Pretty print
	encoded.clear();
	StringSource(cipher, true,
		new HexEncoder(
			new StringSink(encoded)
		) // HexEncoder
	); // StringSource
	cout << "cipher text: " << encoded << endl;

	return cipher;
}

std::pair<std::vector<unsigned char>, std::vector<byte> > EncDecClass::decryptCert(string cert, byte * key, int key_size, byte * iv, int iv_size){
	string recovered;
	const byte separator[] = {0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00};
	string str_cert, str_r, str_sep;

	//unsigned char * cert_other_party;
	//byte * r_other_party;
	string encoded;

	HexEncoder encoder;
	encoder.Put(separator, sizeof(separator));
	encoder.MessageEnd();

	int size = encoder.MaxRetrievable();
	if(size)
	{
		str_sep.resize(size);		
		encoder.Get((byte*)str_sep.data(), str_sep.size());
	}


	try
	{
		CTR_Mode< AES >::Decryption d;
		d.SetKeyWithIV(key, key_size, iv);

		// The StreamTransformationFilter removes
		//  padding as required.
		StringSource s(cert, true, 
			new StreamTransformationFilter(d,
				new StringSink(recovered)
			) // StreamTransformationFilter
		); // StringSource

		std::size_t found = recovered.find(str_sep);
		if (found!=std::string::npos){
			str_cert = recovered.substr(0,found);
			str_r    = recovered.substr(found + sizeof(separator)*2,recovered.size());
		}
		


		//StringSource(recovered, true,
		//	new HexEncoder(
		//		new StringSink(encoded)
		//	) // HexEncoder
		//); // StringSource
		cout << "recovered text: " << endl;
		cout << recovered << endl;
	}
	catch(const CryptoPP::Exception& e)
	{
		cerr << e.what() << endl;
	}
	//cert_other_party = new unsigned char[str_cert.length()/2];
	std::stringstream ss;
	//std::string hex = "0c45a1bf";
	std::vector<unsigned char> hexChcert;
	unsigned int buffer;
	int offset = 0;
	int i = 0;
	while (offset < str_cert.length()) {
	   ss.clear();
	   ss << std::hex << str_cert.substr(offset, 2);
	   ss >> buffer;
	   //*(cert_other_party++) = static_cast<unsigned char>(buffer);
	   hexChcert.push_back(static_cast<unsigned char>(buffer));
	   //cert_other_party++;
	   offset += 2;
	}

	offset = 0;
	std::vector<byte> hexChR;
	while (offset < str_r.length()) {
	   ss.clear();
	   ss << std::hex << str_r.substr(offset, 2);
	   ss >> buffer;
	   hexChR.push_back(static_cast<byte>(buffer));
	   offset += 2;
	}

	return std::pair<std::vector<unsigned char>, std::vector<byte> >(hexChcert,hexChR);
}