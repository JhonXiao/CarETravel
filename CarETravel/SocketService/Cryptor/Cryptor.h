//
//  Cryptor.h
//  NetSocketLib
//
//  Created by revenco on 13-11-8.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cryptor : NSObject

+(NSData *)encryptUseDES:(NSData *)plainText key:(NSString *)key;

+(NSData *)decryptUseDES:(NSData *)cipherText key:(NSString *)key;

+(NSString*)enLoginPwd:(NSString*)loginPwd withAccout:(NSString*)account;

+ (NSString*)encryptUseCaesar:(NSString*)pwdText;

@end
