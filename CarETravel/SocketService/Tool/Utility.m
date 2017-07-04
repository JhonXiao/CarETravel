//
//  Utility.m
//  NetSocketLib
//
//  Created by revenco on 13-11-7.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#import "Utility.h"
#import "Utility_Protected.h"
#include <arpa/inet.h>
#include "ts_sid.h"
#include "endecrypt.h"
#import "UtilityBase64.h"
#import "Reachability.h"
#import "Cryptor.h"

NSString * GLOBALP;               //服务器端发过来参数
NSString * GLOBALG;               //服务器端发过来参数
NSString * GLOBALPubkey;          //服务器端发过来参数

NSString * GLOBALClientPubKey;    //本地DH实例得到的公钥
NSString * GLOBALClientKey;       //本地DH实例与公钥计算协商得到的密钥

NSString * GLOBALKEY;             //数据加密/解密密钥
NSString * GLOBALOldKey;          //数据加密/解密默认密钥

//base64
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation Utility

+ (NSString *)generateSessionID:(int)loginId {
    char sid_str[65] = {0};
	int dest_len = 64;
	int loginid = loginId;
    if(get_sid_str(loginid, sid_str, dest_len)!=0)
        return NULL;
    NSString *result = [[NSString alloc] initWithCString:sid_str encoding:NSASCIIStringEncoding];
    return [result autorelease];
}

//网络序->机器序
+ (header_t)ntohlWithhead:(header_t)header {
    header_t dst;
    dst.version = ntohl(header.version);
	dst.length  = ntohl(header.length);
	dst.command = ntohl(header.command);
	dst.vendor_id = ntohl(header.vendor_id);
	dst.market = ntohl(header.market);
	dst.is_cksum = ntohl(header.is_cksum);
	dst.check_sum = ntohl(header.check_sum);
	dst.extend = ntohl(header.extend);
    return dst;
}

//网络序->机器序
+ (header_t)ntohlWithData:(NSData*)data {
    const char *pData = [data bytes];
    
    header_t dst;
    dst.version = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.length  = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.command = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.vendor_id = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.market = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.is_cksum = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.check_sum = ntohl(*(uint32_t *)pData);
    pData += sizeof(uint32_t);
	dst.extend = ntohl(*(uint32_t *)pData);
    
//    printf("command: %X\n",dst.command);
    
    
    return dst;
}

//机器序->网络序
+ (header_t)htonlWithhead:(header_t)header {
    header_t dst;
    dst.version = htonl(header.version);
	dst.length  = htonl(header.length);
	dst.command = htonl(header.command);
	dst.vendor_id = htonl(header.vendor_id);
	dst.market = htonl(header.market);
	dst.is_cksum = htonl(header.is_cksum);
	dst.check_sum = htonl(header.check_sum);
	dst.extend = htonl(header.extend);
    return dst;
}

int parse_header(const char *str, int len, header_t header) {
	uint32_t *ptr=(uint32_t *)str;
	header.version   = ntohl(*ptr);
	ptr+=1;
	header.length    = ntohl(*ptr);
    ptr+=1;
	header.command   = ntohl(*ptr);
	ptr+=1;
	header.vendor_id = ntohl(*ptr);
	ptr+=1;
	header.market    = ntohl(*ptr);
	ptr+=1;
	header.is_cksum  = ntohl(*ptr);
	ptr+=1;
	header.check_sum = ntohl(*ptr);
	ptr+=1;
	header.extend    = ntohl(*ptr);
	return 0;
}

int assemble_header(header_t *header,char *writeptr,int *wlen) {
	uint32_t version   = 1;
	uint32_t length    = 0;
	uint32_t command   = 0;
	uint32_t vender_id = 1;
	uint32_t market    = 10;
	uint32_t is_cksum  = 0;
	uint32_t check_sum = 0;
	uint32_t extend    = 0;
    
	uint32_t len = sizeof(uint32_t);
	uint32_t offset = 0;
    
	version = htonl(version);
	memcpy(writeptr + offset, &version, len);
    
	offset += len;
	length = htonl(header->length);
	memcpy(writeptr + offset, &length, len);
    
	offset += len;
	command = htonl(header->command);
	memcpy(writeptr + offset, &command, len);
    
	offset += len;
	vender_id = htonl(vender_id);
	memcpy(writeptr + offset, &vender_id, len);
    
	offset += len;
	market = htonl(market);
	memcpy(writeptr + offset, &market, len);
    
	offset += len;
	is_cksum = htonl(header->is_cksum);
	memcpy(writeptr + offset, &is_cksum, len);
    
	offset += len;
	check_sum = htonl(header->check_sum);
	memcpy(writeptr + offset, &check_sum, len);
    
	offset += len;
	extend = htonl(header->extend);
	memcpy(writeptr + offset, &extend, len);
    
	offset += len;
	*wlen = (int)offset;
	return 0;
}

+ (NSInteger)getCurrentTimeOfSecond {
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    return time;
}

+ (NSString *)parseByte2HexString:(Byte *) bytes {
    NSMutableString *hexStr = [[[NSMutableString alloc]init] autorelease];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    
    return hexStr;
}

+ (NSString *)parseByteArray2HexString:(Byte[]) bytes
{
    NSMutableString *hexStr = [NSMutableString string];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    
    return hexStr;
}

+ (NSData *)parseBodyData:(NSData *)data withHeadLen:(int)headLen withBodyLen:(int)bodyLen {
    Byte *inByte = (Byte *)[data bytes];
    inByte += headLen;
    NSData *adata = [[NSData alloc] initWithBytes:inByte length:bodyLen];
    return [adata autorelease];
}

+ (void)genarateDHKey{
    int num = 0;
    int *status = &num;
    if(GLOBALPubkey == NULL || GLOBALP == NULL || GLOBALG == NULL){
        NSLog(@"get dhkey is error,dh is null.");
        return;
    }
    
    const char *cP = [GLOBALP cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cG = [GLOBALG cStringUsingEncoding:NSASCIIStringEncoding];
    DH *dh = init_B_key(status, cP , cG);
    if(dh == NULL){
        NSLog(@"init_B_key() error");
        return;
    }
    
    GLOBALClientPubKey = [[NSString alloc] initWithUTF8String:BN_bn2hex(dh->pub_key)];
    if(dh->pub_key == NULL){
        NSLog(@"dh->pub_key is null");
        return;
    }
    
    int len = 0;
    unsigned char * tmpKey = get_key(dh, GLOBALPubkey.UTF8String, &len);
    if(tmpKey == NULL){
        NSLog(@"get_key is error,tmpKey is null.");
        return;
    }
    
    char cclientKey[130] = {0};
    char *ptr = cclientKey;
    
    for (int j=0; j<len; j++) {
        sprintf(ptr, "%02X",tmpKey[j]);
        ptr += 2;
    }
    
    GLOBALClientKey = [[NSString alloc] initWithUTF8String:cclientKey];
    
    return ;
}

+ (NSString*)computeEnpytKeySummary {
    char enyKey[65] = {0};
    computeEnpytKeySummary([GLOBALClientKey UTF8String],[GLOBALClientKey length],enyKey);
    return [[[NSString alloc] initWithUTF8String:enyKey] autorelease];
}

+ (void)genarateDefaultKey
{
    char defaultKey[66] = {0};
    getDefaultKey(defaultKey);
    GLOBALOldKey = [[NSString alloc] initWithCString:defaultKey encoding:(NSASCIIStringEncoding)];
    GLOBALKEY = [[NSString alloc] initWithString:GLOBALOldKey];
}

+ (NSString*)getClientPubKey
{
    return GLOBALClientPubKey;
}

+ (NSString*)getDESKey
{
    return GLOBALKEY;
}

+ (void)exchangeKeyOK:(NSString*)p withG:(NSString*)g withPubKey:(NSString*)pubKey
{
    GLOBALP = [[NSString alloc] initWithString:p];
    GLOBALG = [[NSString alloc] initWithString:g];
    GLOBALPubkey = [[NSString alloc] initWithString:pubKey];
}

+ (void)exchangeKeyCheckOK
{
    GLOBALKEY = GLOBALClientKey;
}

+ (NSData *)parseHexStr2Byte:(NSString *)hexStr
{
    // 16进制字符串解析为二进制数组
    NSString *hexString = [[hexStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length] < 1)
        return nil;
    Byte result[1] = {0};
    NSMutableData *bytes=[NSMutableData data];
    for (int i = 0;i< [hexString length]/2; i++) {
        
        unichar hex_char1 = [hexString characterAtIndex:i*2]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        
        unichar hex_char2 = [hexString characterAtIndex:i*2+1]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        result[0] = int_ch1 + int_ch2;
        [bytes appendBytes:result length:1];
    }
    return bytes;
}

+ (NSData *)parseBase64EncodedString2Data:(NSString *)string
{
    // 解析BASE64字符串
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
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
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

+ (NSData *)encryptUseDES:(NSData *)plainText key:(NSString *)key
{
    return [Cryptor encryptUseDES:plainText key:key];
}

+ (NSData *)decryptUseDES:(NSData *)cipherText key:(NSString *)key
{
    return [Cryptor decryptUseDES:cipherText key:key];
}

+ (NSString*)encryptLoginPwd:(NSString*)loginPwd withAccout:(NSString*)account
{
    return [Cryptor enLoginPwd:loginPwd withAccout:account];
}

+ (NSString*)encryptCaesar:(NSString*)pwdText
{
    NSString *text = [UtilityBase64 base64StringFromText:pwdText];
    return [Cryptor encryptUseCaesar:text];
}

//检测是否连接到网络
+ (BOOL)netWorkReachability
{
    BOOL ret = NO;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([r currentReachabilityStatus])
    {
        case NotReachable:
        {
            ret = NO;
        }
            break;
        case ReachableViaWWAN:
        {
            ret = YES;
        }
            break;
        case ReachableViaWiFi:
        {
            ret = YES;
        }
            break;
    }
    return ret;
}

@end
