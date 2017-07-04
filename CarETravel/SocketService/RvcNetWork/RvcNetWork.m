//
//  RvcNetWork.m
//  YongWeiPan
//
//  Created by revenco on 16/12/16.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import "RvcNetWork.h"
#import "NetSocketHelper.h"
#import "RvcHeader.h"
#import "IoPacket.h"
#import "TcpResponse.h"
#import "QuotesPush.h"

@interface RvcNetWork()<TlsSocketDelegate>
@property (nonatomic, strong) GcdNetSocket * netSocket;
@end

@implementation RvcNetWork
@synthesize response     = _delegate;

#pragma mark - Property

+ (RvcNetWork *)shared
{
    static RvcNetWork *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RvcNetWork alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _netSocket = [GcdNetSocket shared];
        _netSocket.delegate = self;
    }
    return self;
}

- (void)closeNetwork{
    
}

- (NSString *)nextSessionID
{
    return [Utility generateSessionID:0];
}

#pragma mark TlsSocketDelegate Methods

- (void)tlsSocketDidConnect:(GcdNetSocket *)client
{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClientDidConnected:)]) {
        [_delegate netSocketClientDidConnected:self];
    }
}

- (void)tlsSocketDidDisconnect:(GcdNetSocket *)client
{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClientDidClosed:)]) {
        [_delegate netSocketClientDidClosed:self];
    }
}

- (void)tlsSocketDidSendTimeOut:(GcdNetSocket *)client;
{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClientDidSendTimeOut:)]) {
        [_delegate netSocketClientDidSendTimeOut:self];
    }
}

- (void)tlsSocketDidSendTimeOut:(GcdNetSocket *)client withCmd:(int)cmd{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClientDidSendTimeOut: withCmd:)]) {
        [_delegate netSocketClientDidSendTimeOut:self withCmd:cmd];
    }
}

- (void)tlsSocketDidSocketConnectTimeOut:(GcdNetSocket *)client
{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClientDidSocketOpenTimeOut:)]) {
        [_delegate netSocketClientDidSocketOpenTimeOut:self];
    }
}

- (void)tlsSocketDidExchangeKeySuccess:(BOOL)res{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClientDidSuccessExchangeKey:)]) {
        [_delegate netSocketClientDidSuccessExchangeKey:res];
    }
}

- (void)tlsSocket:(int)method didReceivedData:(id)data
{
    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClient:withMethod:didReceivedData:)]) {
        TcpResponse *tcpResponse = data;
        if (tcpResponse.prototype != kPrototypePost) {
            return;
        }
        [_delegate netSocketClient:self withMethod:method didReceivedData:data];
    }
}

//当前推送商品报价
- (void)tlsSocket:(int)method didPushData:(id)data
{
//    if (_delegate && [_delegate respondsToSelector:@selector(netSocketClient:withMethod:didPushData:)]) {
//        TcpResponse *tcpResponse = data;
//        if (tcpResponse.prototype != kPrototypePush) {
//            return;
//        }
//        [_delegate netSocketClient:self withMethod:method didPushData:data];
//    }
    TcpResponse *tcpResponse = data;
//    if (tcpResponse.prototype != kPrototypePush) {
//        return;
//    }
    [[QuotesPush quotesShared] receviceQuotesInfo:data];
}

#pragma mark UI发起请求的方法

- (void)getValidateCodeWithPhoneNum:(NSString *)phoneNo sessionID:(NSString *)sid {
    NSDictionary *parameters = @{@"SID": sid, @"PhoneNumber": phoneNo};
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_GetValidateCode withData:parameters];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)registerWithPhoneNumber:(NSString *)phoneNum withLoginPwd:(NSString *)pwd withValidateCode:(NSString *)code withSessionID:(NSString *)sid{
    NSDictionary *parameters = @{@"SID": sid, @"PhoneNumber": phoneNum, @"LoginPwd": pwd, @"Code": code};
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_UserRegister withData:parameters];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)doLogin:(NSString *)account
   withPassword:(NSString *)pwd
   withUserType:(int32_t)userType
  withSessionID:(NSString *)sid
{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    [packet setValue:account forKey:@"LoginAccount"];
    [packet setValue:pwd forKey:@"LoginPwd"];
    NSNumber *uType = [NSNumber numberWithInteger:userType];
    [packet setValue:uType forKey:@"UserType"];
    [[NetSocketHelper shared] setUserName:account];
    [[NetSocketHelper shared] setUserPassword:pwd];

    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_Login withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)serviceListQueryLoginId:(int32_t)l withSessionID:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_ServeList withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)userServeOrderListQueryLoginId:(int32_t)l withStatus:(int32_t)s withSessionID:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber *status = [NSNumber numberWithInteger:s];
    [packet setValue:status forKey:@"Status"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_UserOrderList withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)orderLoginId:(int32_t)l withServeId:(int32_t)serId withPrice:(Float64)p withDiscount:(Float64)disc withQuantity:(int32_t)q withAmount:(Float64)a withSessionSid:(NSString *)sid{
//    NSLog(@"price:%f,discount:%f,amount:%f",p,disc,a);
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber *serviceId = [NSNumber numberWithInteger:serId];
    [packet setValue:serviceId forKey:@"ServiceID"];
    NSNumber *price = [NSNumber numberWithDouble:p];
    [packet setValue:price forKey:@"Price"];
    NSNumber *disCount = [NSNumber numberWithDouble:disc];
    [packet setValue:disCount forKey:@"Discount"];
    NSNumber *amount = [NSNumber numberWithDouble:a];
    [packet setValue:amount forKey:@"Amount"];
    NSNumber *quantity = [NSNumber numberWithInteger:q];
    [packet setValue:quantity forKey:@"Quantity"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_UserServeOrder withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)orderPaymentWithLoginId:(int32_t)l withOrderId:(int64_t)oId withAmount:(double)a withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber *amount = [NSNumber numberWithDouble:a];
    [packet setValue:amount forKey:@"Amount"];
    NSNumber *orderId = [NSNumber numberWithLongLong:oId];
    [packet setValue:orderId forKey:@"OrderID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_OrderPayment withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)getUserBalanceWithLoginId:(int32_t)l withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_GetUserBalance withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)chargeWithLoginId:(int32_t)l withAmount:(Float64)a withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber *amount = [NSNumber numberWithInteger:a];
    [packet setValue:amount forKey:@"Amount"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_UserCharge withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)queryUserDataWithLoginId:(int32_t)l withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_GetUserInfo withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)userInfoModWithLoginId:(int32_t)l withUserInfo:(RefineUserInfo *)reUserInfo withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    [packet setObject:reUserInfo forKey:@"UserInfo"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_UserInfoMod withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)orderBarcodeBindWithLoginID:(int32_t)l withOrderId:(int64_t)orId withBarcode:(NSString *)bcode withBindType:(int32_t)bType withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber * orderId = [NSNumber numberWithLongLong:orId];
    [packet setValue:orderId forKey:@"OrderID"];
    [packet setValue:bcode forKey:@"BarCode"];
    NSNumber *bindType = [NSNumber numberWithInteger:bType];
    [packet setValue:bindType forKey:@"BindType"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_OrderBarcodeBind withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)checkScanCodeWithLoginID:(int32_t)l withBarcode:(NSString *)bcode withUserType:(int32_t)uType withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    [packet setValue:bcode forKey:@"BarCode"];
    NSNumber *userType = [NSNumber numberWithInteger:uType];
    [packet setValue:userType forKey:@"UserType"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_QuickBarcodeBind withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)cancelOrderWithLoginId:(int32_t)l withOrderId:(int64_t)orId withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber * orderId = [NSNumber numberWithLongLong:orId];
    [packet setValue:orderId forKey:@"OrderID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_CancelOrder withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)customerServiceQueryWithLoginID:(int32_t)l withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_GetCSInfo withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)changePasswdWithLoginId:(int32_t)l withUserType:(int32_t)utype withOldPwd:(NSString *)oldPwd withNewPwd:(NSString *)newPwd withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber *userType = [NSNumber numberWithInteger:utype];
    [packet setValue:userType forKey:@"UserType"];
    [packet setValue:oldPwd forKey:@"OldPwd"];
    [packet setValue:newPwd forKey:@"NewPwd"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_ChagePasswd withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)queryCarBandWithLoginId:(int32_t)l withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_CarBand withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

- (void)queryCarTypeWithLoginId:(int32_t)l withCarBand:(int32_t)carBand withSessionSid:(NSString *)sid{
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setValue:sid forKey:@"SID"];
    NSNumber *loginId = [NSNumber numberWithInteger:l];
    [packet setValue:loginId forKey:@"LoginID"];
    NSNumber *cband = [NSNumber numberWithInteger:carBand];
    [packet setValue:cband forKey:@"CarBand"];
    
    IoPacket * sendPacket = [[NetSocketHelper shared] corePacketWithCmd:Req_CarType withData:packet];
    [[GcdNetSocket shared] sendWithUI:sendPacket];
}

@end
