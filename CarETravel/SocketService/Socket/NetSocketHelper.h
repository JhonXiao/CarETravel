//
//  NetSocketHelper.h
//  YongWeiPan
//
//  Created by revenco on 16/12/15.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface NetSocketHelper : NSObject

@property (nonatomic, retain) NSString     * exchangeKey;
@property (nonatomic, retain) NSString     * exchangeOldKey;
@property (nonatomic, assign) BOOL           exchangeOK;
@property (nonatomic, assign) BOOL           exchangeCheckOK;
@property (nonatomic, assign) NSTimeInterval heartbeatTimeout;
@property (nonatomic, assign) NSTimeInterval autoLoginTimeOut;
@property (nonatomic, assign) NSTimeInterval exchangeTimeout;
@property (nonatomic, assign) NSInteger      lastHeartbeat;
@property (nonatomic, assign) NSInteger      lastExchangeKey;

@property (nonatomic, retain) NSString     * userName;
@property (nonatomic, retain) NSString     * userPassword;
@property (nonatomic, assign) NSInteger      loginID;
@property (nonatomic, assign) NSInteger      userID;
@property (nonatomic, assign) NSInteger      memberID;
@property (nonatomic, retain) NSString     * loginAccount;

+ (NetSocketHelper *)shared;

- (void)changeExChangeState:(BOOL)state;

- (NSData *)coreEncryptSendData:(NSData *)data;
- (NSData *)coreDecryptRecvData:(NSData *)data;

//- (void)coreParseFilterWithCmd:(NSInteger)cmd withData:(NSData *)data;
//- (BOOL)coreParseExchangeFilterWithCmd:(NSInteger)cmd withData:(NSData *)data;

- (id)corePacketWithSendHeartbeat:(NSInteger)interval;
- (id)corePacketWithSendExchangeKey:(NSInteger)interval;
- (id)corePacketWithSendExchangeCheckKey:(NSInteger)interval;

- (id)corePacketWithCmd:(NSInteger)cmd withData:(NSDictionary *)parameters;
- (id)coreParseWithCmd:(NSInteger)cmd withData:(NSData *)data outDataWithSid:(NSString **)sid outDataWithType:(prototype_t*)protoType;

@end
