//
//  UICode.h
//  NetClient
//
//  Created by sunrise on 14-3-17.
//  Copyright (c) 2014年 com.sunrise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UICode : NSObject
{
    NSDictionary *_codeDict;
    NSInteger _logonCount;
}

+ (UICode *)sharedClient;

- (NSString *)messageWithCode:(NSInteger)code;
- (NSString *)messageWithCode:(NSInteger)code withLogonCount:(NSInteger)count;

@end
