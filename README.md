### Summary

This is a demo project using Crypto++ for iOS.
See Crypto++ project page [http://www.cryptopp.com/](http://www.cryptopp.com/) for more info.

### Build the static universal library

1. open the Terminal and enter external/scripts directory.
2. then, type ./build-cryptopp.sh
3. if succeeded, external/include/cryptopp/*.h and external/lib/libcryptopp.a is there. 

check libcryptopp.a using file commad like this

> file external/lib/libcryptopp.a
> 
> external/lib/libcryptopp.a: Mach-O universal binary with 4 architectures
> 
> external/lib/libcryptopp.a (for architecture i386):	current ar archive random library
> 
> external/lib/libcryptopp.a (for architecture armv6):	current ar archive random library
> 
> external/lib/libcryptopp.a (for architecture armv7):	current ar archive random library
> 
> external/lib/libcryptopp.a (for architecture armv7s):	current ar archive random library
      
now, you get a universal binary of Crypto++

### Build demo app

1. Double click Cryptopp-for-iOS.xcodeproj
2. Just run with XCode. That't too easy.

Currently, only hash algorithm MD5/SHA examples are available.

### License

Crypto++ is based on public domain license, 
So I decided to apply this demo app the public domain license.

Have fun with Crypto++ on the iOS devices!

Addition
--------

### Original project

[https://github.com/3ign0n/CryptoPP-for-iOS](https://github.com/3ign0n/CryptoPP-for-iOS)

### Require
 
1. Xcode Command Line Tools
2. iOS 6.1 SDK

If you want to compile other sdk, modify "CryptoPP-for-iOS/external/scripts/build-cryptopp.sh" the following files
  
```sh
SDK_VERSION="6.1"
```

### Compiled static library

download [cryptopp.562.a.7z (i386,armv6,armv7,armv7s)](http://pan.baidu.com/share/link?shareid=169474345&uk=993244828)

You can use it directly

### Use it in Xcode

Config your Xcode project, otherwise it will compile error

1. Set "C++ Language Dialect" and "C++ standard Library" is "Compiler Default"
2. Add "Header Search Paths"

```
"$(SRCROOT)/external/include"
"$(SRCROOT)/external/include/cryptopp"
``` 

3. Add "Library Search Paths"

```
"$(SRCROOT)/external/lib"
``` 