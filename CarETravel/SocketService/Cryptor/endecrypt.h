/*
 *endecrypt.h
 *利用openssl数据加解密
 */
#ifndef _ENDECRYPT_H
#define _ENDECRYPT_H

/*openssl*/
#include <openssl/crypto.h>
#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/dh.h>
#include <openssl/bio.h>
#include <openssl/bn.h>
#include <openssl/rand.h>
#include <string.h>
#include <stdbool.h>

#define MS_CALLBACK
static int MS_CALLBACK cb(int p,int n,BN_GENCB *arg);
static const char rnd_seed[]= "string to make dh test";
static const char ssl_content[]="PMECDH";
//加密
int   myencrypt(unsigned char*in_out_data,unsigned long*len,unsigned char*Key);
//解密
int   mydecrypt(unsigned char*in_out_data,unsigned long*len,unsigned char*Key);
//密钥协商
unsigned char*get_key(DH*dh,const char*pub,int*out);
DH*   init_B_key(int *status,const char*p,const char*g);
void  sha256encrypt(char*pInData, unsigned long nLen,char pOutData[65]);
int computeEnpytKeySummary(const char*key ,const unsigned long keyLen,char * sumary);

void  init_crc_table(uint nCrcTb[]);
uint  crc32(const char*buffer,unsigned long size,uint nTable[]);

//default key
int  getDefaultKey(char * defaultKey);
#endif
