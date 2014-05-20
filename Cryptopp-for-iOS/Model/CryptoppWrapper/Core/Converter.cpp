#include "Converter.h"


std::string Converter::SecByteBlockToString(SecByteBlock data){
	Integer a = decodeSecByteBlock(data);
	std::ostringstream oss;
	oss << std::hex << a;
	std::string s(oss.str());
	s = s.substr(0, 2*data.SizeInBytes()+1); //Do zapamiêtania. d³ugoœæ stringa z s wynosi 2*d³ugoœæ w bytach plus 1.
	return s;
}

void Converter::FromStringToSecByteblock(std::string data, SecByteBlock * sbb_data, int size){
	Integer a(data.c_str());
	a.Encode(*sbb_data, size);
	if(data.compare(SecByteBlockToString(*sbb_data))!=0){
		std::cout << "Error while encoding string to SecByteBlock" << std::endl;
	}
}

//void Converter::TestIntegerAndSecByteBlock(Integer a, SecByteBlock * sbb){
//	std::cout<<"Jako integer: "<<std::hex<<a<<std::endl;
//	std::string s = SecByteBlockToString(*sbb);
//	std::cout<<"Jako string: "<<std::hex<<s<<std::endl;
//}

//********************************************************************************************************
Integer Converter::decodeSecByteBlock(SecByteBlock key)
{
    Integer x;
    x.Decode(key.BytePtr(), key.SizeInBytes());
    return x;
}
//********************************************************************************************************
SecByteBlock Converter::encodeSecByteBlock(Integer key)
{
    int length = key.MinEncodedSize();
    byte * byteX = new byte[length];
	
    key.Encode(byteX, length);
    
    SecByteBlock pubKeyA;
    pubKeyA.Assign(byteX, length);

    //check
    if (key != decodeSecByteBlock(pubKeyA))
        std::cout << "Error while encoding Integer to SecByteBlock" << std::endl;
    
    return pubKeyA;
}



std::string Converter::IntegerToString(Integer i)
{
    std::ostringstream oss;
    oss << i;
    return oss.str();
}

std::string Converter::ByteToString(byte * data, int length){
	std::string s(reinterpret_cast<char const*>(data), length);
	return s;
}

void Converter::test(){
}