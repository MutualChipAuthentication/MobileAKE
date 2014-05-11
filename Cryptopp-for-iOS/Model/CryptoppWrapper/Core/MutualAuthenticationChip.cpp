#include "MutualAuthenticationChip.h"


void MutualAuthenticationChip::GenerateKeyPairs(){
	privateKey = new SecByteBlock(dh.PrivateKeyLength()); //xA - private key
	publicKey = new SecByteBlock(dh.PublicKeyLength());   //yA = g^xA - public key
	kg->GenerateStaticKeyPair(rnd, *privateKey, *publicKey); 
}

void MutualAuthenticationChip::GenerateEphemeralKeys(){
	ephemeralPublicKey = new SecByteBlock(dh2->EphemeralPublicKeyLength()); //hA = H(a)
	ephemeralPrivateKey = new SecByteBlock(dh2->EphemeralPrivateKeyLength()); //cA = g^hA
	
    kg->GenerateEphemeralKeyPair2(rnd, ephemeralPrivateKey, ephemeralPublicKey);
}

std::string MutualAuthenticationChip::GetEphemeralPublicKey(){
	return Converter::SecByteBlockToString(*ephemeralPublicKey);
}


int MutualAuthenticationChip::GetKeySize(){
	return keySize;
}

std::string MutualAuthenticationChip::ShowPublicKey(){
	string s = Converter::SecByteBlockToString(*publicKey);
	return s;
}

std::string MutualAuthenticationChip::ShowPrivateKey(){
	string s = Converter::SecByteBlockToString(*privateKey);
	return s;
}



void MutualAuthenticationChip::GetEphemeralPublicKey2(byte * epubK, size_t &size){
	//string s = Converter::SecByteBlockToString(*ephemeralPublicKey);
	//cout << "Ephemeral public key in the function: " << std::hex << s << endl;
	//epubK = ephemeralPublicKey->BytePtr();
	//cout << "rozmiar: " << ephemeralPublicKey->size() << endl;
	//cout << "rozmiar2: " << (size_t)ephemeralPublicKey->size() << endl;
	//Integer a;
	//a.Decode(epubK, (size_t)ephemeralPublicKey->size());
	//std::ostrstream oss;
	//oss << std::hex << a;
	//std::string s2(oss.str());
	////std::string s2((char *) epubK, (size_t)ephemeralPublicKey->size());
	//cout << "Ephemeral public key after byte itp: " << std::hex << s2 << endl;
	//std::string s3((char *) epubK, (size_t)ephemeralPublicKey->size());
	//cout << "Ephemeral public s3: " << std::hex << s3 << endl;
	//size = (size_t)ephemeralPublicKey->size();
}


void MutualAuthenticationChip::SetEphemeralPublicKeyAnotherParty(std::string data){
	CryptoPP::Integer Cb;
	CryptoPP::Integer hA;
	CryptoPP::Integer K;
	CryptoPP::Integer xA;
	CryptoPP::Integer cb_to_xa;

	this->K_byte = new SecByteBlock(AES::DEFAULT_KEYLENGTH); //K = cB^hA
	this->Ka = new byte[AES::DEFAULT_KEYLENGTH]; // KA = H(K,1)
	this->Kb = new byte[AES::DEFAULT_KEYLENGTH]; // KB = H(K,2)
	this->Ka_prim = new byte[AES::DEFAULT_KEYLENGTH]; // KA_prim = H(K,3)
	this->Kb_prim = new byte[AES::DEFAULT_KEYLENGTH]; // KB_prim = H(K,4)
	this->rA = new byte[HashClass::size]; //rA = H(cB^xA, KA_prim)
	
	cout<< "From part: "<<part<<endl;

	ephemeralPublicKeyAnotherParty = new SecByteBlock(dh2->EphemeralPublicKeyLength());
	Converter::FromStringToSecByteblock(data, ephemeralPublicKeyAnotherParty, dh2->EphemeralPublicKeyLength());
	Cb.Decode(ephemeralPublicKeyAnotherParty->BytePtr(), ephemeralPublicKeyAnotherParty->SizeInBytes());
	hA.Decode(ephemeralPrivateKey->BytePtr(), ephemeralPrivateKey->SizeInBytes());

	K = a_exp_b_mod_c(Cb, hA, this->p); //K = cB^hA

	cout<<"K partu: "<<part<<" "<<K<<endl;
	K.Encode(*this->K_byte, AES::DEFAULT_KEYLENGTH);

	this->Ka = kg->GenerateKeyFromHashedKey(*this->K_byte, AES::DEFAULT_KEYLENGTH, 1); //KA = H(K,1)
	this->Kb = kg->GenerateKeyFromHashedKey(*this->K_byte, AES::DEFAULT_KEYLENGTH, 2); // KB = H(K,2)
	this->Ka_prim = kg->GenerateKeyFromHashedKey(*this->K_byte, AES::DEFAULT_KEYLENGTH, 3); // KA_prim = H(K,3)
	this->Kb_prim = kg->GenerateKeyFromHashedKey(*this->K_byte, AES::DEFAULT_KEYLENGTH, 4); // KB_prim = H(K,4)

	xA.Decode(this->privateKey->BytePtr(), this->privateKey->SizeInBytes()); //xA - private key
	
	cb_to_xa = a_exp_b_mod_c(Cb, xA, this->p); // cB^xA
	byte * cb_to_xa_byte = new byte[dh2->EphemeralPublicKeyLength()];
	cb_to_xa.Encode(cb_to_xa_byte, dh2->EphemeralPublicKeyLength());

	if(is_initializator)
		rA = kg->GenerateKeyFromHashedKeySec(cb_to_xa_byte, Ka_prim, AES::DEFAULT_KEYLENGTH ); //rA = H(cB^xA, KA_prim)
	else
		rA = kg->GenerateKeyFromHashedKeySec(cb_to_xa_byte, Kb_prim, AES::DEFAULT_KEYLENGTH ); //rB = H(cA^xB, KB_prim)
}


void MutualAuthenticationChip::EncryptCertKey(){
	string test = "testowowowona pewnoe jkhsdajgdjhgjbcmxzgigsajdghsma bjjdgsagdj";
	const char* test_c = test.c_str();
	test.size();
	byte * test_b = (byte*)test_c;
	if(is_initializator){
		this->cipher = edc.EncryptCertAndRa(test_b, test.size(),
											rA, HashClass::size,
											Ka, AES::DEFAULT_KEYLENGTH);
	}else{
		this->cipher = edc.EncryptCertAndRa(test_b, test.size(),
											rA, HashClass::size,
											Kb, AES::DEFAULT_KEYLENGTH);
	}
}

void MutualAuthenticationChip::DecryptCertKey(string cipher){
	string decrypted_cert;
	byte * decrypted_ra = new byte[HashClass::size];
	int decrypted_ra_size;
	if(is_initializator){
		edc.DecryptCertAndRa(cipher, Ka, AES::DEFAULT_KEYLENGTH, 
							&decrypted_cert, decrypted_ra, &decrypted_ra_size);
		int n = memcmp( rA, decrypted_ra, HashClass::size);
		if(n == 0){
			cout<<" Ra takie samo po deszyfracji "<<endl;
		}else{
			cout<<"Cos jest nie tak"<<endl;
		}
	}else{
		edc.DecryptCertAndRa(cipher, Kb, AES::DEFAULT_KEYLENGTH, 
							&decrypted_cert, decrypted_ra, &decrypted_ra_size);
		int n = memcmp( rA, decrypted_ra, HashClass::size);
		if(n == 0){
			cout<<" Ra takie samo po deszyfracji "<<endl;
		}else{
			cout<<"Cos jest nie tak"<<endl;
		}
	
	}
}

SecByteBlock MutualAuthenticationChip::GetEphemeralPublicKey2(){
	return *ephemeralPublicKey;
}