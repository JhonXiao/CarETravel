//
//  RvcNetWork.h
//  YongWeiPan
//
//  Created by revenco on 16/12/16.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "GcdNetSocket.h"
#import "TcpResponse.h"

@protocol NetSocketDelegate <NSObject>
@optional
- (void)netSocketClientDidConnected:(id)netSocket;
- (void)netSocketClientDidClosed:(id)netSocket;
- (void)netSocketClientDidSendTimeOut:(id)netSocket;
- (void)netSocketClientDidSendTimeOut:(id)netSocket withCmd:(int)cmd;
- (void)netSocketClientDidSocketOpenTimeOut:(id)netSocket;
- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data;
- (void)netSocketClient:(id)netSocket withMethod:(int)method didPushData:(id)data;
- (void)netSocketClientDidSuccessExchangeKey:(BOOL)res;
@end

@interface RvcNetWork : NSObject

@property (nonatomic, assign)   id<NetSocketDelegate> response; //socket响应代理

+ (RvcNetWork *)shared;
- (void)closeNetwork;
- (NSString *)nextSessionID;

- (void)getValidateCodeWithPhoneNum:(NSString *)phoneNo sessionID:(NSString *)sid;
- (void)registerWithPhoneNumber:(NSString *)phoneNum withLoginPwd:(NSString *)pwd withValidateCode:(NSString *)code withSessionID:(NSString *)sid;
// 用户登录
- (void)doLogin:(NSString *)account
   withPassword:(NSString *)pwd
   withUserType:(int32_t)userType
  withSessionID:(NSString *)sid;
- (void)serviceListQueryLoginId:(int32_t)l withSessionID:(NSString *)sid;

- (void)userServeOrderListQueryLoginId:(int32_t)l withStatus:(int32_t)s withSessionID:(NSString *)sid;

- (void)orderLoginId:(int32_t)l withServeId:(int32_t)serId withPrice:(Float64)p withDiscount:(Float64)disc withQuantity:(int32_t)q withAmount:(Float64)a withSessionSid:(NSString *)sid;

- (void)orderPaymentWithLoginId:(int32_t)l withOrderId:(int64_t)oId withAmount:(double)a withSessionSid:(NSString *)sid;

- (void)getUserBalanceWithLoginId:(int32_t)l withSessionSid:(NSString *)sid;

- (void)chargeWithLoginId:(int32_t)l withAmount:(Float64)a withSessionSid:(NSString *)sid;
- (void)queryUserDataWithLoginId:(int32_t)l withSessionSid:(NSString *)sid;
- (void)userInfoModWithLoginId:(int32_t)l withUserInfo:(RefineUserInfo *)reUserInfo withSessionSid:(NSString *)sid;
- (void)orderBarcodeBindWithLoginID:(int32_t)l withOrderId:(int64_t)orId withBarcode:(NSString *)bcode withBindType:(int32_t)bType withSessionSid:(NSString *)sid;
- (void)customerServiceQueryWithLoginID:(int32_t)l withSessionSid:(NSString *)sid;
- (void)changePasswdWithLoginId:(int32_t)l withUserType:(int32_t)utype withOldPwd:(NSString *)oldPwd withNewPwd:(NSString *)newPwd withSessionSid:(NSString *)sid;
- (void)checkScanCodeWithLoginID:(int32_t)l withBarcode:(NSString *)bcode withUserType:(int32_t)uType withSessionSid:(NSString *)sid;
- (void)cancelOrderWithLoginId:(int32_t)l withOrderId:(int64_t)orId withSessionSid:(NSString *)sid;
- (void)queryCarBandWithLoginId:(int32_t)l withSessionSid:(NSString *)sid;
- (void)queryCarTypeWithLoginId:(int32_t)l withCarBand:(int32_t)carBand withSessionSid:(NSString *)sid;

@end
