//
//  Utility_Protected.h
//  NetSocketLib
//
//  Created by revenco on 14-6-27.
//  Copyright (c) 2014年 sunrise. All rights reserved.
//

typedef struct _protohead
{
    unsigned int version:32;       //版本
    unsigned int length:32;        //包头+包体
    unsigned int command:32;       //命令字
    unsigned int vendor_id:32;     //客户端厂商标志
    unsigned int market:32;        //市场标志
    unsigned int is_cksum:32;      //是否检查校验和
    unsigned int check_sum:32;     //校验和
    unsigned int extend:32;        //保留
} header_t;

#import "Utility.h"

@interface Utility ()

+ (header_t)ntohlWithhead:(header_t)header;     //网络序->机器序
+ (header_t)ntohlWithData:(NSData*)data;        //网络序->机器序
+ (header_t)htonlWithhead:(header_t)header;     //机器序->网络序

@end

int parse_header(const char *str, int len, header_t header);
