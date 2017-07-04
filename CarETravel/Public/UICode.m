//
//  UICode.m
//  NetClient
//
//  Created by sunrise on 14-3-17.
//  Copyright (c) 2014年 com.sunrise. All rights reserved.
//

#import "UICode.h"
#import "Config.h"

@implementation UICode

+ (UICode *)sharedClient {
    __strong static UICode *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UICode alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
	if((self = [super init]))
	{
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"RetCode" ofType:@"plist"];
        _codeDict = [[NSDictionary alloc]initWithContentsOfFile:plist];
    }
    return self;
}

- (NSString *)messageWithCode:(NSInteger)code
{
    NSString *key = [NSString stringWithFormat:@"%ld",(long)code];
    if (!_codeDict || ![_codeDict objectForKey:key]) {
        return [NSString stringWithFormat:@"%@[%ld]", @"返回超时",(long)code];
    }
    switch (code) {
        case SUCESSED_CODE: {
            return kParseRetCodeOK;
        }
            break;
        case FORCEOFF_CODE: {
            return (NSString *)[_codeDict objectForKey:key];
        }
            break;
        default:{
            return (NSString *)[_codeDict objectForKey:key];
        }
            break;
    }
}

- (NSString *)messageWithCode:(NSInteger)code withLogonCount:(NSInteger)count
{
    NSString *key = [NSString stringWithFormat:@"%ld",(long)code];
    if (!_codeDict || ![_codeDict objectForKey:key])
    {
        return [NSString stringWithFormat:@"%@[%ld]", @"返回超时",(long)code];
    }
    switch (code)
    {
        case SUCESSED_CODE:
        {
            return kParseRetCodeOK;
        }
            break;
        case FORCEOFF_CODE:
        {
            return (NSString *)[_codeDict objectForKey:key];
        }
            break;
        case 4004:
        {
            if (0==count)
            {
                return @"该帐号已经被系统锁定，系统会在10分钟后自动解锁，或者您可以联系会员单位解锁";
            }
            NSString *message = [NSString stringWithFormat:@"密码不符！请输入正确密码！您还有%ld次登录的机会，如果失败，该帐号将会被系统锁定。",(long)count];
            return message;
        }
            break;
        default:
        {
            return (NSString *)[_codeDict objectForKey:key];
        }
            break;
    }
}

@end
