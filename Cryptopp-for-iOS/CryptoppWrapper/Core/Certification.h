#pragma once
#include <stdio.h>
#include <stdlib.h>
#ifdef __cplusplus
extern "C" {
#endif
	#include <openssl/pem.h>
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" {
#endif
	#include <openssl/conf.h>
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
	#include <openssl/x509v3.h>
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
	#include <openssl/x509.h>
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
	#include <openssl/x509_vfy.h>
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
#ifndef OPENSSL_NO_ENGINE
	#include <openssl/engine.h>
#endif
	#ifdef __cplusplus
}
#endif
#undef X509_NAME
class Certification
{
public:
	Certification(void);
	~Certification(void);
	int MakeCertificate(X509 **x509p, EVP_PKEY **pkeyp, int bits, int serial, int days);
	int add_ext(X509 *cert, int nid, char *value);
	static void callback(int p, int n, void *arg);
	
	int Test();
};

