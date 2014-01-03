//
//  NSData+base64.m
//  Fetion
//
//  Created by zypsg on 9/2/09.
//  Copyright 2009 zyp company. All rights reserved.
//

#import "NSData+base64.h"
#import <string>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//void urldecode(char *p)
//{
//    int i=0;
//    while(*(p+i))
//    {
//        if ((*p=*(p+i)) == '%')
//        {
//            *p=*(p+i+1) >= 'A' ? ((*(p+i+1) & 0XDF) - 'A') + 10 : (*(p+i+1) - '0');
//            *p=(*p) * 16;
//            *p+=*(p+i+2) >= 'A' ? ((*(p+i+2) & 0XDF) - 'A') + 10 : (*(p+i+2) - '0');
//            i+=2;
//        }
//        else if (*(p+i)=='+')
//        {
//            *p=' ';
//        }
//        p++;
//    }
//    *p='\0';
//}

@implementation NSString (URLENCODE)

-(NSString *)rawUrlEncode
{
    return [self rawUrlEncodeByEncoding:NSUTF8StringEncoding];
}

-(NSString *)rawUrlEncodeByEncoding:(NSStringEncoding)code
{
    NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding((unsigned long)code))) autorelease];
    return newString;
    /*
    std::string src = [self UTF8String]; 
    char hex[] = "0123456789ABCDEF";  
    std::string dst;  
    for (size_t i = 0; i < src.size(); ++i)  
    {    
        unsigned char cc = src[i];  
        if (isascii(cc))         
        {           
            if (cc == ' ')             
            {  
                dst += "%20";                  
            }        
            else 
            {
                dst += cc;      
            }  
        }
        else
        {   
            unsigned char c = static_cast<unsigned char>(src[i]);     
            dst += '%';    
            dst += hex[c / 16];   
            dst += hex[c % 16];  
        }
    }
    
    if (dst.length()>0) {
        NSString* newString = [NSString stringWithUTF8String:dst.c_str()];
        newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        return newString;
    }
    else
        return nil;
     */
}

-(NSString *)rawUrlDecode
{
    std::string result;  
    int hex = 0;  
    std::string szToDecode = [self UTF8String]; 
    for (size_t i = 0; i < szToDecode.length(); ++i)  
    {
        switch (szToDecode[i])      
        {            
            case '+':         
                result += ' ';       
                break;        
            case '%':        
                if (isxdigit(szToDecode[i + 1]) && isxdigit(szToDecode[i + 2]))            
                {              
                    std::string hexStr = szToDecode.substr(i + 1, 2);            
                    hex = strtol(hexStr.c_str(), 0, 16);            
                    //字母和数字[0-9a-zA-Z]、一些特殊符号[$-_.+!*'(),] 、以及某些保留字[$&+,/:;=?@]            
                    //可以不经过编码直接用于URL              
                    if (!((hex >= 48 && hex <= 57) || //0-9                                    
                          (hex >=97 && hex <= 122) ||   //a-z                                 
                          (hex >=65 && hex <= 90) ||    //A-Z                                 
                          //一些特殊符号及保留字[$-_.+!*'(),]  [$&+,/:;=?@]                                   
                          hex == 0x21 || hex == 0x24 || hex == 0x26 || hex == 0x27 || hex == 0x28 || hex == 0x29                                  
                          || hex == 0x2a || hex == 0x2b|| hex == 0x2c || hex == 0x2d || hex == 0x2e || hex == 0x2f                                 
                          || hex == 0x3A || hex == 0x3B|| hex == 0x3D || hex == 0x3f || hex == 0x40 || hex == 0x5f))           
                    {              
                        result += char(hex);              
                        i += 2;          
                    }  
                    else 
                        result += '%';  
                }
                else 
                {  
                    result += '%';  
                }  
                break;  
            default:  
                result += szToDecode[i];  
                break;  
        }  
    }  
    return [NSString stringWithUTF8String:result.c_str()];
}

@end

@implementation NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string
{
	if (string == nil)
		return nil;
	//[NSException raise:NSInvalidArgumentException format:nil];
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = (char*)malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSUTF8StringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = (char*)malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding
{
	if ([self length] == 0)
		return @"";
	
    char *characters = (char*)malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [self length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length])
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

/*
 *使用base64编码处理数据.
 **/
+ (id) dataToBase64Encoded:(NSData*)data
{
	if(data!=nil&&[data length]>0)
	{
		NSString *base64Str=[data base64Encoding];
		return [base64Str dataUsingEncoding:NSUTF8StringEncoding];
	}
	return nil;
}
/*
 *还原base64编码的数据.
 **/
+ (id) dataFromBase64Encoded:(NSData*)base64Data
{
	if(base64Data!=nil&&[base64Data length]>0)
	{
		NSString *base64Str=[[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
		NSData *data=[NSData dataWithBase64EncodedString:base64Str];
		[base64Str release];
		return data;
	}
	return nil;
}



@end