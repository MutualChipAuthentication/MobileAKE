#pragma once
#include <iostream>
#include <string>
#include <strstream>
#include "Converter.h"
#include "KeyGenerator.h"
//#include "mac/Hash.h"
#include "EncDecClass.h"
#include "secblock.h"
using CryptoPP::SecByteBlock;

#include "integer.h"
using CryptoPP::Integer;

#include "osrng.h"
using CryptoPP::AutoSeededRandomPool;

#include "dh.h"
using CryptoPP::DH;

class MutualAuthenticationChip {
private:
	string part;
	int help;
	int keySize;
	Integer p, q, g;
	SecByteBlock * publicKey;
	SecByteBlock * privateKey;
	bool is_initializator;
	SecByteBlock * ephemeralPrivateKey;
	SecByteBlock * ephemeralPublicKeyAnotherParty;
	SecByteBlock * publicKeyAnotherParty;
	SecByteBlock * K_byte;
	SecByteBlock * K_session_key;
	byte * rA;
	byte * rB;
	DH dh;
	DH2 * dh2;
	EncDecClass edc;
	KeyGenerator *kg;
	byte * iv;
	int size_of_key_init_vect;
	Integer ComputeK();
	void SetKeysAnotherParty(string ephKey, string pubKey);
	Integer ComputeEphemeralKeyAnotherValueToPrivateKey();
	Integer ComputePublicKeyAnotherPartyToEphemeralKey();
	void TestOfPower();
	void ComputeSessionKey();
public:
	string cipher;
	MutualAuthenticationChip(AutoSeededRandomPool &rnd, string h = "A"): part(h) {
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
		Integer v = ModularExponentiation(g, q, p);
        rnd.Reseed(false);

		dh.AccessGroupParameters().Initialize(this->p, this->q, this->g);

		kg = new KeyGenerator(dh);
		
		dh2 = new DH2(dh);
		keySize = HashClass::size;
        is_initializator = false;
        if (h == "A")
        {
            Integer pubKey = CryptoPP::Integer("30222313103416484737728074612425214126734791862902310075404137175196490255087357276634530623209055864437547252587560242012951252123883845471428300996630382283841646354968561208085927173525510706082475459851860792820176457822967649557768154303922217472248717392402506600192733705517151755320886806822808293568");
            Integer privKey = Integer("760986887347144154595862811575615374796752848751");
            
            publicKey = Converter::createSecByteBlock(pubKey);
            privateKey = Converter::createSecByteBlock(privKey);
        }
        else if (h == "B")
        {
            Integer pubKey = CryptoPP::Integer("14937252435456816444315144988606834394405620177779470871314613282765209100656000546289874717514307843372460147271927179132591019166403117763752044377923030284277665081681429636803343669361207907144378001193776859330592525966966787427742150822910770827385205862373202130377453205416037048248518669196478538474");
            Integer privKey = Integer("556487849058594585561145389138531342141308623513");
            publicKey = Converter::createSecByteBlock(pubKey);
            privateKey = Converter::createSecByteBlock(privKey);
        }
        else
            this->GenerateKeyPairs(rnd);
        this->GenerateEphemeralKeys(rnd);
	}
	SecByteBlock * ephemeralPublicKey;
    Integer getP() { return p; }
    Integer getQ() { return q; }
    Integer getG() { return g; }
	
	
    MutualAuthenticationChip(Integer p, Integer q, Integer g)
    : p(p), q(q), g(g) {}

    void GenerateKeyPairs(AutoSeededRandomPool &rnd);
    void GenerateEphemeralKeys(AutoSeededRandomPool &rnd);
    void GetEphemeralPublicKey2(byte * epubKey, size_t & size);
	int CompareRa(byte * decrypted_ra);
	std::string GetEphemeralPublicKey();
    std::string ShowPublicKey();
    std::string ShowPrivateKey();
    std::string ShowSessionKey();
    std::string ShowOtherPartyPublicKey();

	void SetEphemeralPublicKeyAnotherParty(std::string str_ephemeralPublicKeyAnotherParty, std::string str_publickKeyAnotherParty, bool isInitalizator);
    int GetKeySize();
	string EncryptCertKey();
	void Generate2(SecByteBlock * publicB, SecByteBlock * privateB);
	bool DecryptCertKey(string cipher);
	SecByteBlock GetEphemeralPublicKey2();
	SecByteBlock GetPublicKey();
	void GenerateSessionKey();
    static void test();
};

