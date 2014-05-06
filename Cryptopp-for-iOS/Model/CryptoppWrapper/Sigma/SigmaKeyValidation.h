//
//  SigmaKeyValidation.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29.10.2013.
//
//

#import <Foundation/Foundation.h>
#include "dh2.h"
using CryptoPP::DH2;

@interface SigmaKeyValidation : NSObject
- (BOOL)simulateSignatures:(CryptoPP::DH2)dhA partyB:(CryptoPP::DH2)dbB;
@end
