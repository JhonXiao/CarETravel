//
//  Cryptor.m
//  NetSocketLib
//
//  Created by revenco on 13-11-8.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#import "Cryptor.h"
#import "CommonCrypto/CommonCryptor.h"
#include "endecrypt.h"
#include "CaesarCrypt.h"

const Byte eniv[] = {1,2,3,4,5,6,7,8};

@implementation Cryptor


//加密
+(NSData *) encryptUseDES:(NSData *)plainText key:(NSString *)key{
    if(plainText == NULL||key == NULL){
        return NULL;
    }
        
    //NSLog(@"encrypt key:%@ plainText:%@",key,plainText);
    
    //int myencrypt(unsigned char*in_out_data,int*len,unsigned char*Key)
    int rtn = -1;
    unsigned long srcLen = [plainText length];
    unsigned char in_out_str[srcLen+128];
    memset(in_out_str, 0, srcLen+128);
    memcpy(in_out_str, plainText.bytes, srcLen);
    
    unsigned char tmpkey[key.length+1];
    memset(tmpkey, 0, key.length+1);
    memcpy(tmpkey, key.UTF8String, key.length);
    rtn = myencrypt(in_out_str,&srcLen,tmpkey);
    
    

    NSData *data = nil;

    if(rtn == 0){
        data = [NSData dataWithBytes:in_out_str length:(NSUInteger)srcLen];
    }
    return data;
}

//解密
+(NSData *)decryptUseDES:(NSData *)cipherText key:(NSString *)key{
    if(cipherText == NULL|| key == NULL){
        return NULL;
    }
    int rtn = -1;
    unsigned long srcLen = [cipherText length];
    unsigned char in_out_str[srcLen+128];
    memset(in_out_str, 0, srcLen+128);
    memcpy(in_out_str, cipherText.bytes, srcLen);
    
    unsigned char tmpkey[key.length+1];
    memset(tmpkey, 0, key.length+1);
    memcpy(tmpkey, key.UTF8String, key.length);
    rtn = mydecrypt(in_out_str,&srcLen, tmpkey);
    
    NSData *plaindata = nil;
    if(rtn == 0){
        plaindata = [NSData dataWithBytes:in_out_str length:(NSUInteger)srcLen];
    }
    return plaindata;
}

+(NSString*) enLoginPwd:(NSString*)loginPwd withAccout:(NSString*)account {
    if(loginPwd == NULL||account == NULL){
        return NULL;
    }
    unsigned long loginLen = [loginPwd length];
    unsigned char login_str[loginLen+128];
    memset(login_str, 0, loginLen+128);
    memcpy(login_str, loginPwd.UTF8String, loginLen);
    
    unsigned long accountLen = [account length];
    unsigned char account_str[accountLen+128];
    memset(account_str, 0, accountLen+128);
    memcpy(account_str, account.UTF8String, accountLen);
    
    unsigned char in_str[loginLen+accountLen+128];
    memset(in_str, 0, loginLen+accountLen+128);
    memcpy((char*)in_str, (char*)login_str,loginLen);
    memcpy((char*)in_str+loginLen, (char*)account_str,accountLen);
    //printf("in_str[%s]\n",in_str);
    //sha256
    char buffer[65] = { 0 };
    sha256encrypt((char*)in_str,loginLen+accountLen,buffer);
    //printf("sha256 buffer[%s]\n",buffer);
    //计算CRC值
    uint crc_table[256];
    char crc[30]    = {0};
    init_crc_table(crc_table);
    unsigned int nCrcValue = crc32(buffer,strlen(buffer), crc_table);
    snprintf(crc,sizeof(crc)-1,"%08x",nCrcValue);
    //printf("crc[%s]\n",crc);
    //凯撒
    char caesar_in_str[128],caesar_out_str[256];
    memset(caesar_in_str, 0, 128);
    memset(caesar_out_str,0,256);
    memcpy(caesar_in_str, buffer,64);
    memcpy(caesar_in_str+64, crc,strlen(crc));
    //printf("caesar_in_str[%s]\n",caesar_in_str);
    CaesarEncryptStr(caesar_in_str,caesar_out_str);
    //printf("caesar_out_str[%s]\n",caesar_out_str);
    NSData * data = [NSData dataWithBytes:caesar_out_str length:(NSUInteger)strlen(caesar_out_str)];
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString*)encryptUseCaesar:(NSString*)pwdText
{
    unsigned long pwdLen = [pwdText length];
    //凯撒
    char caesar_in_str[128],caesar_out_str[256];
    memset(caesar_in_str,0, 128);
    memset(caesar_out_str,0, 256);
    memcpy(caesar_in_str, pwdText.UTF8String,pwdLen);
    //printf("caesar_in_str[%s]\n",caesar_in_str);
    CaesarEncryptStr(caesar_in_str,caesar_out_str);
    //printf("caesar_out_str[%s]\n",caesar_out_str);
    NSData * data = [NSData dataWithBytes:caesar_out_str length:(NSUInteger)strlen(caesar_out_str)];
    NSString *result = [[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] autorelease];
    return result;
}

+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString*)key {
    
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    //    NSString *key = @"123456789012345678901234";
    NSString *initVec = @"init Vec";
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [initVec UTF8String];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       vinitVec, //"init Vec", //iv,
                       vplainText, //"Your Name", //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else if (ccStatus == kCC ParamError) return @"PARAM ERROR";
     else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
     else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
     else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
     else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
     else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED"; */
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                length:(NSUInteger)movedBytes]
                                        encoding:NSUTF8StringEncoding]
                  autorelease];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];

    }
    
    return result;
    
}


+(void) cryptWithReq:(NSString*) req WithKey:(NSString*)key{
    //NSString* req = @"234234234234234中国";
    //NSString* key = @"888fdafdakfjak;";
    //NSString* ret1 = [[NSString alloc]init];
    
    NSString* ret1 = [ self TripleDES:req encryptOrDecrypt:kCCEncrypt key:key];
    NSLog(@"3DES Encode Result=%@", ret1);
    
    NSString* ret2 = [self TripleDES:ret1 encryptOrDecrypt:kCCDecrypt key:key];
    NSLog(@"3DES Decode Result=%@", ret2);


}


@end
