//
//  Utility.h
//  NetSocketLib
//
//  Created by revenco on 13-11-7.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
// 

typedef enum _prototype
{
    kPrototypePost = 1,            //正常响应类型
    kPrototypePush = 2             //推送数据类型
} prototype_t;

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString *)parseByte2HexString:(Byte *)bytes;             //BYTE->16进制字符串
+ (NSString *)parseByteArray2HexString:(Byte[])bytes;        //BYTE数组->16进制字符串
+ (NSData *)parseHexStr2Byte:(NSString *)hexStr;             //16进制字符串->BYTE
+ (NSData *)parseBase64EncodedString2Data:(NSString *)string;//BASE64字符串->NSDATA
+ (NSData *)parseBodyData:(NSData *)data
              withHeadLen:(int)headLen
              withBodyLen:(int)bodyLen;                      //解析数据包体

+ (NSInteger)getCurrentTimeOfSecond;             //获取距离1970的秒数
+ (NSString *)generateSessionID:(int)loginId;    //生成SID
+ (NSString*)computeEnpytKeySummary;             //计算摘要
+ (void)genarateDHKey;                           //生成DH实例
+ (void)genarateDefaultKey;                      //生成默认密钥
+ (NSString*)getClientPubKey;                    //DH实例公钥
+ (NSString*)getDESKey;                          //数据加密密钥
+ (void)exchangeKeyOK:(NSString*)p
                withG:(NSString*)g
           withPubKey:(NSString*)pubKey;         //交换密钥成功
+ (void)exchangeKeyCheckOK;                      //密钥检验成功
+ (NSData *)encryptUseDES:(NSData *)plainText
                      key:(NSString *)key;       //数据加密
+ (NSData *)decryptUseDES:(NSData *)cipherText
                      key:(NSString *)key;       //数据解密
+ (NSString*)encryptLoginPwd:(NSString*)loginPwd
                  withAccout:(NSString*)account; //用户名密码加密
+ (NSString*)encryptCaesar:(NSString*)pwdText;   //凯撒加密
+ (BOOL)netWorkReachability;                     //网络是否可用

@end
