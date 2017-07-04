/*
 *endecrypt.cpp
 * 利用openssl中DES_ede3_cbc_encrypt 进行加解密
 */
#include <openssl/des.h>
#include <openssl/evp.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include "endecrypt.h"
#include <math.h>


//using namespace std;
int  ret, which = 1;
const unsigned char iv[] = {0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8};

int myencrypt(unsigned char*in_out_data,unsigned long*len,unsigned char*Key){
    //取密钥的前20位作为加密密钥,这里数组必须用24大小。
    unsigned char enyptKey[24] = {0};
    unsigned long nKeylen = strlen((char*)Key);
    unsigned long nLen = (nKeylen < 20) ? nKeylen : 20;
    memcpy(enyptKey, Key, nLen);
    const EVP_CIPHER    *cipher=EVP_des_ede3_cbc(); 
    EVP_CIPHER_CTX ciph_ctx;
    unsigned long unin_len = * len;
    //int in_len = * len;
    int in_len = (int)unin_len;
    unsigned char out[in_len+512];//,dec_data[in_len+512]; 
    int      outl,total;
    OpenSSL_add_all_algorithms();
    EVP_CIPHER_CTX_init(&ciph_ctx);
    if(EVP_EncryptInit_ex(&ciph_ctx, cipher, NULL, enyptKey, iv) == 0){ 
        printf("EVP_EncryptInit_ex error\n");
        return -1;
    }
    total=0; 
    if(EVP_EncryptUpdate(&ciph_ctx,out,&outl,(const unsigned char*)in_out_data,in_len)==0 ){
        printf("EVP_EncryptUpdate error\n"); 
        return -1;
    }
    total+=outl; 

    if(EVP_EncryptFinal(&ciph_ctx,out+total,&outl)==0 ) { 
        printf("EVP_EncryptFinal error\n");
        return -1; 
    }
    total+=outl; 
    memcpy(in_out_data , out, total);
    *len = total; 
    EVP_CIPHER_CTX_cleanup(&ciph_ctx);
    return 0;
}

int mydecrypt(unsigned char*in_out_data,unsigned long*len, unsigned char *Key){
    //取密钥的前20位作为加密密钥,这里数组必须用24大小。
    unsigned char enyptKey[24] = {0};
    unsigned long nKeylen = strlen((char*)Key);
    unsigned long nLen = (nKeylen < 20) ? nKeylen : 20;
    memcpy(enyptKey, Key, nLen);
    const EVP_CIPHER    *cipher=EVP_des_ede3_cbc(); 
    EVP_CIPHER_CTX ciph_ctx;  
    unsigned long unin_len = * len;
    //int in_len = * len;
    int in_len = (int)unin_len;
    unsigned char in[in_len+128],dec_data[in_len+128];
    memset(in,0,in_len+128); 
    memset(dec_data,0,in_len+128); 
    int outl,total;
    total = in_len;
    memcpy(in , in_out_data ,in_len);
    OpenSSL_add_all_algorithms();
    EVP_CIPHER_CTX_init(&ciph_ctx);
    if(EVP_DecryptInit_ex(&ciph_ctx, cipher, NULL, enyptKey, iv) == 0){ 
        printf("EVP_DecryptInit_ex error\n"); 
        return -1;
    }
    if( EVP_DecryptUpdate(&ciph_ctx,dec_data,&outl,in,total) == 0){ 
        printf("EVP_DecryptUpdate error\n"); 
        return -1;
    }
    total=outl; 
    if(EVP_DecryptFinal(&ciph_ctx,dec_data+total,&outl) == 0){
        printf("EVP_DecryptFinal error.error is %s.outl=%d\n",strerror(errno),outl); 
        return -1;
    }
    total+=outl; 
    dec_data[total]=0; 
    memcpy(in_out_data , dec_data, total);
    *len = total; 
    EVP_CIPHER_CTX_cleanup(&ciph_ctx);
    return 0;
}
/*功能：模拟客户端接收到A发送的p g然后初始化客户端的DH实例
 *参数：
 *     status -作为函数执行状态返回码，根据不同的程序运行情况返回不同值
 *     p g 分别为服务端发送到客户端的参数
 *
 *返回：客户端DH实例
 */
DH*init_B_key(int *status,const char*p,const char*g)
{
    int ret=0;
    //新建DH 并将pg 赋值 初始化
    DH *b = DH_new();
    ret = BN_hex2bn(&(b->p),p);
    ret = BN_hex2bn(&(b->g),g);

    //产生私钥及公钥
    if(!DH_generate_key(b))
        goto err;
    *status = 0;
    return b;
    
    err:
    *status = -1;
    return NULL;
}
/*功能：根据本地的DH实例及得到的公钥计算协商得到的密钥
 *参数：
 *     dh 本地DH实例指针
 *     pub 公钥字符串
 *     out int类型指针，用于返回协商密钥的长度值，使得(*out)= 协商密钥长度
 *     
 *返回：buf 返回密钥-字符串指针（无符号字符）
 */
unsigned char*get_key(DH*dh,const char*pub,int*out){
    BIGNUM *pubkey =NULL;
    //将字符串转换并赋值给大数
    BN_hex2bn(&pubkey,pub);
    int len = DH_size(dh);
    //分配内存空间
    unsigned char *buf = (unsigned char*)OPENSSL_malloc(len);
    if(NULL==buf)
        return NULL;
    *out = DH_compute_key(buf,pubkey,dh);//计算协商密钥
    return buf;
}

//回调函数  在这里用途不大 
static int MS_CALLBACK cb(int p,int n,BN_GENCB *arg)
{
    return 1;
}

void sha256encrypt(char*pInData, unsigned long nLen, char pOutData[65])
{
    unsigned char hash[SHA256_DIGEST_LENGTH]; 
    SHA256_CTX sha256; 
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, pInData, nLen); 
    SHA256_Final(hash, &sha256);
    
    for(int i=0; i < SHA256_DIGEST_LENGTH; i++)
    {
        sprintf(pOutData+(i*2), "%02x", hash[i]);
    }
    pOutData[64] = 0;
}
/*计算摘要*/
int computeEnpytKeySummary(const char*key,const unsigned long keyLen,char * sumary){
    //char*enyKey=(char*)malloc(65);
    //if(NULL==enyKey)
    //    return NULL;
    //char enyKey[65] = {0};
    //memset(enyKey,0x0,65);
    char _key[500]  = {0};
    uint crc_table[256];
    char crc[30]    = {0}; 

    init_crc_table(crc_table);
    //计算CRC值
    unsigned int nCrcValue = crc32(key,keyLen, crc_table);
      
    snprintf(crc,sizeof(crc)-1,"%08x",nCrcValue);
    snprintf(_key,sizeof(_key)-1,"%s%s",key,crc);
    unsigned long len = keyLen + strlen(crc);

    sha256encrypt(_key,len,sumary);
    return 1;
}


/* 
**初始化crc表,生成32位大小的crc表 
**也可以直接定义出crc表,直接查表, 
**但总共有256个,看着眼花,用生成的比较方便. 
*/
void init_crc_table(uint nCrcTb[]){
    int i,j;
    uint crc;
    for(i = 0;i < 256;i++){
        crc = i;
        for(j = 0;j < 8;j++){
            if(crc & 1){
                 crc = (crc >> 1) ^ 0xEDB88320;
            }else{
                 crc = crc >> 1;
            }
        }
        nCrcTb[i] = crc;
    }
}
/*计算buffer的crc校验码*/
unsigned int crc32(const char *buffer, unsigned long size, uint nTable[]){
    uint crc =0xFFFFFFFF;
    int init = 0;
    if(!init){
        init_crc_table(nTable);
        init =1;
    }

    for(int i=0; i<size; i++){
        crc = (crc >> 8) ^ nTable[(crc & 0xFF) ^ buffer[i]];     
    }
    crc ^= 0xFFFFFFFF;  
    return crc;
}
int divide(bool updateSum, bool positive, bool updateDividend,
           int digits, long long sum[], long long dividend[], long long divisor,
           long long BASE)
{
    long long quotient = 0;
    long long remainder = 0;
    int i;
    for (i = digits; i >= 0; i--) {
        quotient = BASE * remainder + dividend[i];
        remainder = quotient % divisor;
        quotient /= divisor;
        if (updateDividend)
            dividend[i] = quotient;
        if (!updateSum)
            continue;
        if (positive)
            sum[i] += quotient;
        else
            sum[i] -= quotient;
    }
    
    if (updateDividend) {
        while (digits > 0 && dividend[digits] == 0) {
            digits--;
        }
    }
    
    return digits;
}
void myfmt(long long pi[], int digits, long long BASE)
{
    long long numerator = 0;
    long long remainder = 0;
    long long quotient = 0;
    int i;
    for (i = 0; i < digits; i++) {
        numerator = pi[i] + quotient;
        quotient = numerator / BASE;
        remainder = numerator % BASE;
        if (remainder < 0) {
            remainder += BASE;
            quotient--;
        }
        pi[i] = remainder;
    }
}
const long long *compute(int digits, long long BASE)
{
    int t0[] = { 176, 57, 28, 239, -48, 682, 96, 12943 };
    int i, step, digits2;
    bool positive;
    long long divisor;
    long long *pi = (long long *) calloc(++digits + 1, sizeof(long long));
    long long *tmp = (long long *) calloc(digits + 1, sizeof(long long));
    for (i = 0; i < sizeof(t0) / sizeof(t0[0]); i += 2) {
        memset(tmp, 0, sizeof(tmp[0]) * (digits + 1));
        tmp[digits] = t0[i];
        divisor = t0[i + 1];
        digits2 = divide(true, true, true, digits, pi, tmp, divisor, BASE);
        positive = false;
        divisor *= divisor;
        for (step = 3; digits2 > 0; positive = !positive, step += 2) {
            digits2 =
            divide(false, true, true, digits2, NULL, tmp, divisor, BASE);
            digits2 =
            divide(true, positive, false, digits2, pi, tmp, step, BASE);
        }
    }
    myfmt(pi, digits, BASE);
    return pi;
}




int getPIvalue(char sPi[150])
{
    int nlen = 10;
    int ndigis = 100;
    int i = ndigis / nlen;
    const long long *pi = NULL;
    long long nBASE = (long long) pow(10, nlen);
    pi = compute(i, nBASE);
    snprintf(sPi, 149, "%lld.", pi[i + 1]);
    printf("%lld.", pi[i + 1]);
    for (; i > 0; i--) {
        snprintf(sPi + strlen(sPi), 149 - strlen(sPi), "%0*lld", nlen, pi[i]);
    }
    return 0;
}

//memcpy(default_encrypt, keybuffer, 65);
int  getDefaultKey(char * defaultKey){
    int len = 20;
    char pi[150] = { 0 };
    getPIvalue(pi);
    char keybuffer[65] = { 0 };
    sha256encrypt(pi, 20 + 2, keybuffer);
    memcpy(defaultKey, keybuffer, len);
    return len;
}
