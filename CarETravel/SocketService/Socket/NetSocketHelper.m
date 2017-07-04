//
//  NetSocketHelper.m
//  YongWeiPan
//
//  Created by revenco on 16/12/15.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import "NetSocketHelper.h"
#import "Etravel.pb.h"
#import "IoPacket.h"
#import "RvcHeader.h"
#import "TcpResponse.h"
#import "UIData.h"
#import "Config.h"
#import "RvcData.h"
//#import "AdditionalBank.h"

@implementation NetSocketHelper

+ (NetSocketHelper *)shared
{
    static NetSocketHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NetSocketHelper alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _heartbeatTimeout         = 20.0;
        _lastHeartbeat            = 0;
        _exchangeTimeout          = 1;
        _lastExchangeKey          = 0;
        _autoLoginTimeOut         = 1;
//        _lastloginTime            = 0;
        
    }
    return self;
}

- (void)customSettingOnOpenSocket
{
    _exchangeOK      = NO;
    _exchangeCheckOK = NO;
//    _userLoginStatus = NO;
}

- (BOOL)exchangeKeyOK
{
    return _exchangeCheckOK;
}

#pragma mark 加密与解密
- (NSData *)coreEncryptSendData:(NSData *)data
{
    NSData *sendData = [Utility encryptUseDES:data key:[Utility getDESKey]];
    return sendData;
}

- (NSData *)coreDecryptRecvData:(NSData *)data
{
    NSData *body =[Utility decryptUseDES:data key:[Utility getDESKey]];
    return body;
}

#pragma mark -----
- (id)corePacketWithSendHeartbeat:(NSInteger)interval
{
    if((interval-_lastHeartbeat) > _heartbeatTimeout || interval == 0)
    {
        _lastHeartbeat = interval;
        
//        PacketHeartReq * heartbeatReqPacket = [[PacketHeartReq alloc] initWithSid:[Utility generateSessionID:0]];
        HeartReq_Builder* heartReqBuilder = [[HeartReq_Builder alloc] init];
        [heartReqBuilder setSid:[Utility generateSessionID:0]];
        HeartReq* heartReq = [heartReqBuilder build];
        
        IoPacket *packet = [[IoPacket alloc]initWithCmd:Req_HeartBeat WithBody:heartReq.data WithSid:NULL];
        return packet;
    }
    return NULL;
}

- (id)corePacketWithSendExchangeKey:(NSInteger)interval
{
    if(!_exchangeOK)
    {
        NSLog(@"SendExchangeKey Do...");

        NSString * sid = [Utility generateSessionID:0];
        ExChangeKeyReq_Builder* reqBuilder = [[ExChangeKeyReq_Builder alloc] init];
        [reqBuilder setSid:sid];
        [reqBuilder setContent:@"PMECDH"];
        ExChangeKeyReq* req = [reqBuilder build];
        
        IoPacket *packet = [[IoPacket alloc] initWithCmd:Req_exchangeKey WithBody:req.data WithSid:NULL];
        return packet;
    }
    return NULL;
}

- (id)corePacketWithSendExchangeCheckKey:(NSInteger)interval
{
    if((_exchangeOK && !_exchangeCheckOK) || interval == 0)
    {
        NSLog(@"SendExchangeCheckKey Do...");
        
        NSString * sid = [Utility generateSessionID:0];
        [Utility genarateDHKey];

        ExChangeCheckKeyReq_Builder* reqBuilder = [[ExChangeCheckKeyReq_Builder alloc] init];
        [reqBuilder setSid:sid];
        [reqBuilder setPubKey:[Utility getClientPubKey]];
        [reqBuilder setKeyDigest:[Utility computeEnpytKeySummary]];

        ExChangeCheckKeyReq* req = [reqBuilder build];

        IoPacket *packet = [[IoPacket alloc] initWithCmd:Req_exchangeCheckKey WithBody:req.data WithSid:NULL];
        return packet;
    }
    return NULL;
}

- (void)changeExChangeState:(BOOL)state{
    _exchangeOK = state;
    _exchangeCheckOK = state;
}

- (id)corePacketWithCmd:(NSInteger)cmd withData:(NSDictionary *)parameters
{
    IoPacket *packet = NULL;
    switch (cmd)
    {
        case Req_ServeList:{
            ServeListQueryReq_Builder* ReqBuilder = [[ServeListQueryReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            
            ServeListQueryReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_UserRegister:{
            UserRegistReq_Builder * ReqBuilder = [[UserRegistReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            [ReqBuilder setPhoneNumber:[parameters objectForKey:@"PhoneNumber"]];
            [ReqBuilder setLoginPwd:[parameters objectForKey:@"LoginPwd"]];
            [ReqBuilder setValidateCode:[parameters objectForKey:@"Code"]];
            
            UserRegistReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_GetValidateCode:{
            GetValidateCodeReq_Builder * ReqBuilder = [[GetValidateCodeReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            [ReqBuilder setPhoneNumber:[parameters objectForKey:@"PhoneNumber"]];
            
            GetValidateCodeReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_Login:
        {
            LogInReq_Builder* ReqBuilder = [[LogInReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            [ReqBuilder setLoginAccount:[parameters objectForKey:@"LoginAccount"]];
            NSString * enPwdStr = [parameters objectForKey:@"LoginPwd"];
//            [Utility encryptLoginPwd:[parameters objectForKey:@"LoginPwd"] withAccout:[parameters objectForKey:@"LoginAccount"]];
            [ReqBuilder setLoginPwd:enPwdStr];
            NSNumber *uType = [parameters objectForKey:@"UserType"];
            [ReqBuilder setUserType:[uType intValue]];
            
            LogInReq* req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_UserOrderList:{
            UserOrderListQueryReq_Builder* ReqBuilder = [[UserOrderListQueryReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            NSNumber *status = [parameters objectForKey:@"Status"];
            [ReqBuilder setStatus:[status intValue]];
            
            UserOrderListQueryReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_UserServeOrder:{
            UserServeOrderReq_Builder * ReqBuilder = [[UserServeOrderReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            NSNumber *serveId = [parameters objectForKey:@"ServiceID"];
            [ReqBuilder setServeId:[serveId intValue]];
            NSNumber *price = [parameters objectForKey:@"Price"];
            [ReqBuilder setPrice:[price doubleValue]];
            NSNumber *discount = [parameters objectForKey:@"Discount"];
            [ReqBuilder setDiscount:[discount doubleValue]];
            NSNumber *amount = [parameters objectForKey:@"Amount"];
            [ReqBuilder setAmount:[amount doubleValue]];
            NSNumber *quantity = [parameters objectForKey:@"Quantity"];
            [ReqBuilder setQuantity:[quantity intValue]];
            
            UserServeOrderReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_GetUserBalance:{
            GetUserBalanceReq_Builder * ReqBuilder = [[GetUserBalanceReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            
            GetUserBalanceReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_UserCharge:{
            UserChargeReq_Builder * ReqBuilder = [[UserChargeReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            NSNumber *am = [parameters objectForKey:@"Amount"];
            [ReqBuilder setAmount:[am doubleValue]];
            
            UserChargeReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_GetUserInfo:{
            GetUserInfoReq_Builder * ReqBuilder = [[GetUserInfoReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            
            GetUserInfoReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_UserInfoMod:{
            UserInfoModReq_Builder * ReqBuilder = [[UserInfoModReq_Builder alloc] init];
            [ReqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [ReqBuilder setLoginId:[loginId intValue]];
            RefineUserInfo * reUserInfo = [parameters objectForKey:@"UserInfo"];
            
            UserInfo_Builder * infoBuilder = [[UserInfo_Builder alloc] init];
            [infoBuilder setName:reUserInfo.name];
            [infoBuilder setSex:reUserInfo.sex];
            [infoBuilder setCarNo:reUserInfo.carNo];
            [infoBuilder setParkSlot:reUserInfo.parkSlot];
            [infoBuilder setParkType:reUserInfo.parkType];
            [infoBuilder setCartype:reUserInfo.carType];
            [infoBuilder setCarColor:reUserInfo.carColor];
            [infoBuilder setDispCarType:reUserInfo.dispCarType];
            
            UserInfo * uReq = [infoBuilder build];
            [ReqBuilder setUserInfoId:uReq];
            
            UserInfoModReq * req = [ReqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_OrderBarcodeBind:{
            OrderBarcodeBindReq_Builder * reqBuilder = [[OrderBarcodeBindReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            NSNumber * orderId = [parameters objectForKey:@"OrderID"];
            [reqBuilder setOrderId:[orderId longLongValue]];
            [reqBuilder setBarcode:[parameters objectForKey:@"BarCode"]];
            NSNumber *bindType = [parameters objectForKey:@"BindType"];
            [reqBuilder setBindType:[bindType intValue]];
            
            OrderBarcodeBindReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_QuickBarcodeBind:{
            CheckScanCodeReq_Builder * reqBuilder = [[CheckScanCodeReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            [reqBuilder setBarcode:[parameters objectForKey:@"BarCode"]];
            NSNumber *userType = [parameters objectForKey:@"UserType"];
            [reqBuilder setUserType:[userType intValue]];
            
            CheckScanCodeReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_OrderPayment:{
            OrderPaymentReq_Builder * reqBuilder = [[OrderPaymentReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            NSNumber * orderId = [parameters objectForKey:@"OrderID"];
            [reqBuilder setOrderId:[orderId longLongValue]];
            NSNumber *amount = [parameters objectForKey:@"Amount"];
            [reqBuilder setAmount:[amount doubleValue]];
            
            OrderPaymentReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_GetCSInfo:{
            GetCSInfoReq_Builder * reqBuilder = [[GetCSInfoReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
           
            GetCSInfoReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_ChagePasswd:{
            ChangePasswdReq_Builder * reqBuilder = [[ChangePasswdReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            NSNumber *uType = [parameters objectForKey:@"UserType"];
            [reqBuilder setUserType:[uType intValue]];
            [reqBuilder setOldpasswd:[parameters objectForKey:@"OldPwd"]];
            [reqBuilder setNewpasswd:[parameters objectForKey:@"NewPwd"]];
            
            ChangePasswdReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_CancelOrder:{
            CancelOrderReq_Builder * reqBuilder = [[CancelOrderReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            NSNumber *orderId = [parameters objectForKey:@"OrderID"];
            [reqBuilder setOrderId:[orderId longLongValue]];
            
            CancelOrderReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_CarBand:{
            GetCarBandReq_Builder * reqBuilder = [[GetCarBandReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            
            GetCarBandReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
        case Req_CarType:{
            GetCartypeReq_Builder * reqBuilder = [[GetCartypeReq_Builder alloc] init];
            [reqBuilder setSid:[parameters objectForKey:@"SID"]];
            NSNumber *loginId = [parameters objectForKey:@"LoginID"];
            [reqBuilder setLoginId:[loginId intValue]];
            NSNumber *carBand = [parameters objectForKey:@"CarBand"];
            [reqBuilder setCarBand:[carBand intValue]];
            
            GetCartypeReq * req = [reqBuilder build];
            packet = [[IoPacket alloc] initWithCmd:cmd WithBody:req.data WithSid:req.sid];
            break;
        }
    }
    return packet;
}

- (id)coreParseWithCmd:(NSInteger)cmd withData:(NSData *)data outDataWithSid:(NSString **)sid outDataWithType:(prototype_t*)protoType
{
//    NSLog(@"RRNetHelp__%08lX",(long)cmd);
    id rtnObject = NULL;
    *protoType = kPrototypePost;
    switch (cmd)
    {
        case Res_Login:
        {
            LogInRes *res = [LogInRes parseFromData:data];
            *sid = res.sid;
            NSLog(@"recode:%d,username:%@,userid:%d,loginId:%d",res.retCode,res.userName,res.userId,res.loginId);
            
//            //            NSLog(@"Login on Code : %d, Do...",res.retCode);
//            if(res.retCode == SUCESSED_CODE)
//            {
////                _userLogined = YES;
////                _userLoginStatus = YES;
//            }
//            if(res.retCode == FORCEOFF_CODE)
//            {
//                *protoType = kPrototypePush;
////                _userLogined = NO;
////                _userLoginStatus = NO;
//            }

            UserResInfo * userInfo = [[UserResInfo alloc] init];
            userInfo.loginID = res.loginId;
            userInfo.userID = res.userId;
            userInfo.userName = res.userName;
            [UIData sharedClient].loginID = res.loginId;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setTag:kLoginResponse];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setResponseData:userInfo];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_GetValidateCode:{
            StandardRes *res = [StandardRes parseFromData:data];
            *sid = res.sid;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setTag:kGetValidateCodeResponse];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setResponseData:res.msg];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_UserRegister:{
            StandardRes * res = [StandardRes parseFromData:data];
            *sid = res.sid;//15245628542
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setTag:kUserRegisterResponse];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setResponseData:res.msg];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_ServeList:{
            ServeListQueryRes * res = [ServeListQueryRes parseFromData:data];
            *sid = res.sid;
            
            for (ServeGroupInfo * element in res.serveGroupsList) {
                if (element) {
                    [[RvcData shared] appendCacheWithMethod:Res_ServeList useBlock:^(id cache, NSError *error)
                     {
                         if ([cache isKindOfClass:[NSMutableArray class]])
                         {
                             NSMutableArray *data = (NSMutableArray *)cache;
                             
                             BOOL addFlag = YES;
                             //begin:code
                             if (data && data.count > 0)
                             {
                                 for (id row in data)
                                 {
                                     if ([(ServiceListInfo*)row serviceId] == element.serveId)
                                     {
                                         addFlag = NO;
                                         break;
                                     }
                                 }
                             }
                             if (addFlag)
                             {
                                 ServiceListInfo * item = [[ServiceListInfo alloc] init];
                                 item.serviceId = element.serveId;
                                 item.serviceCode = element.serveCode;
                                 item.serviceName = element.serveName;
                                 item.price = element.price;
                                 item.desc = element.desc;
                                 item.iconIndex = element.iconIndex;
                                 
                                 if (item)
                                 {
                                     [data addObject:item];
                                 }
                             }
                             //end
                         }
                     }];
                }
            }

            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kServiceResponse];
            [tcpResponse setResponseData:[[RvcData shared] dataObjWithMethod:Res_ServeList]];
            [[RvcData shared] removeDataObjForMethod:Res_ServeList];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_UserOrderList:{
            UserOrderListQueryRes * res = [UserOrderListQueryRes parseFromData:data];
            *sid = res.sid;
            
            for (OrderGroupInfo * element in res.orderGroupsList) {
                if (element) {
                    [[RvcData shared] appendCacheWithMethod:Res_UserOrderList useBlock:^(id cache, NSError *error)
                     {
                         if ([cache isKindOfClass:[NSMutableArray class]])
                         {
                             NSMutableArray *data = (NSMutableArray *)cache;
                             
                             BOOL addFlag = YES;
                             //begin:code
                             if (data && data.count > 0)
                             {
                                 for (id row in data)
                                 {
                                     if ([(UserOrderListInfo*)row orderId] == element.orderId)
                                     {
                                         addFlag = NO;
                                         break;
                                     }
                                 }
                             }
                             if (addFlag)
                             {
                                 UserOrderListInfo * item = [[UserOrderListInfo alloc] init];
                                 item.serviceId = element.serveId;
                                 item.orderId = element.orderId;
                                 item.orderNum = element.orderNum;
                                 item.serviceNum = element.serveNum;
                                 item.serviceName = element.serveName;
                                 item.price = element.price;
                                 item.disCount = element.discount;
                                 item.quantity = element.quantity;
                                 item.amount = element.amount;
                                 item.status = element.status;
                                 item.createDate = element.createDate;
                                 item.paidDate = element.paidDate;
                                 item.userBarCode = element.userBarcode;
                                 item.userPickPwd = element.userPickPwd;
                                 item.desc = element.desc;
                                 item.gridId = element.gridId;
                                 item.gridInfo = element.gridInfo;
                                 
                                 if (item)
                                 {
                                     [data addObject:item];
                                 }
                             }
                             //end
                         }
                     }];
                }
            }
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kUserOrderListResponse];
            [tcpResponse setResponseData:[[RvcData shared] dataObjWithMethod:Res_UserOrderList]];
            [[RvcData shared] removeDataObjForMethod:Res_UserOrderList];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_UserServeOrder:{
            UserServeOrderRes * res = [UserServeOrderRes parseFromData:data];
            *sid = res.sid;
            
            UserOrderInfo * orderInfo = [[UserOrderInfo alloc] init];
            orderInfo.loginID = res.loginId;
            orderInfo.orderId = res.orderId;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kUserOrderResponse];
            [tcpResponse setResponseData:orderInfo];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_GetUserBalance:{
            GetUserBalanceRes * res = [GetUserBalanceRes parseFromData:data];
            *sid = res.sid;
            
            NSNumber * balanceNum = [NSNumber numberWithDouble:res.balance];
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kGetUserBalanceResponse];
            [tcpResponse setResponseData:balanceNum];
            
            rtnObject = tcpResponse;
            break;
        }
        case Res_UserCharge:{
            StandardRes * res = [StandardRes parseFromData:data];
            *sid = res.sid;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kUserChargeResponse];
            [tcpResponse setResponseData:res.msg];
            rtnObject = tcpResponse;
            break;
        }
        case Res_GetUserInfo:{
            GetUserInfoRes * res = [GetUserInfoRes parseFromData:data];
            *sid = res.sid;
            
            RefineUserInfo * refineUInfo = [[RefineUserInfo alloc] init];
            refineUInfo.name = res.userInfoId.name;
            refineUInfo.sex = res.userInfoId.sex;
            refineUInfo.carNo = res.userInfoId.carNo;
            refineUInfo.parkSlot = res.userInfoId.parkSlot;
            refineUInfo.parkType = res.userInfoId.parkType;
            refineUInfo.carType = res.userInfoId.cartype;
            refineUInfo.carColor = res.userInfoId.carColor;
            refineUInfo.dispCarType = res.userInfoId.dispCarType;
//            refineUInfo.carNo2 = res.userInfoId.carNo2;
//            refineUInfo.carNo3 = res.userInfoId.carNo3;
//            refineUInfo.defaultNo = res.userInfoId.defaultNo;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kGetUserInfoResponse];
            [tcpResponse setResponseData:refineUInfo];
            rtnObject = tcpResponse;
            break;
        }
        case Res_UserInfoMod:{
            StandardRes * res = [StandardRes parseFromData:data];
            * sid = res.sid;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kModifyUserInfoResponse];
            [tcpResponse setResponseData:res.msg];
            rtnObject = tcpResponse;
            break;
        }
        case Res_OrderBarcodeBind:{
            OrderBarcodeBindRes * res = [OrderBarcodeBindRes parseFromData:data];
            *sid = res.sid;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kOrderBarcodeBindResponse];
//            [tcpResponse setResponseData:res.loginId];
            rtnObject = tcpResponse;
            break;
        }
        case Res_QuickBarcodeBind:{
            CheckScanCodeRes * res = [CheckScanCodeRes parseFromData:data];
            *sid = res.sid;
            
            CheckScanCodeInfo * checkInfo = [[CheckScanCodeInfo alloc] init];
            checkInfo.orderId = res.orderId;
            checkInfo.status = res.status;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kCheckScanCodeResponse];
            [tcpResponse setResponseData:checkInfo];
            rtnObject = tcpResponse;
            break;
        }
        case Res_CancelOrder:{
            CancelOrderRes * res = [CancelOrderRes parseFromData:data];
            *sid = res.sid;
            
            CancelOrderInfo * info = [[CancelOrderInfo alloc] init];
            info.loginId = res.logindId;
            info.payType = res.payType;
            info.params = res.params;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kCancelOrderResponse];
            [tcpResponse setResponseData:info];
            rtnObject = tcpResponse;
            break;
        }
        case Res_OrderPayment:{
            OrderPaymentRes * res = [OrderPaymentRes parseFromData:data];
            *sid = res.sid;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kOrderPaymentResponse];
            rtnObject = tcpResponse;
            break;
        }
        case Res_GetCSInfo:{
            GetCSInfoRes * res = [GetCSInfoRes parseFromData:data];
            *sid = res.sid;
            
            CSInfo * csInfo = [[CSInfo alloc] init];
            csInfo.csInfo = res.csinfo;
            csInfo.version = res.version;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kGetCSInfoResponse];
            [tcpResponse setResponseData:csInfo];
            rtnObject = tcpResponse;
            break;
        }
        case Res_ChagePasswd:{
            StandardRes * res = [StandardRes parseFromData:data];
            * sid = res.sid;
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kChangePasswdResponse];
            [tcpResponse setResponseData:res.msg];
            rtnObject = tcpResponse;
            break;
        }
        case Res_CarType:{
            GetCartypeRes * res = [GetCartypeRes parseFromData:data];
            * sid = res.sid;
            
            for (CartypeInfo * element in res.cartypeGroupList) {
                if (element) {
                    [[RvcData shared] appendCacheWithMethod:Res_CarType useBlock:^(id cache, NSError *error)
                     {
                         if ([cache isKindOfClass:[NSMutableArray class]])
                         {
                             NSMutableArray *data = (NSMutableArray *)cache;
                             
                             BOOL addFlag = YES;
                             //begin:code
                             if (data && data.count > 0)
                             {
                                 for (id row in data)
                                 {
                                     if ([(CartypeInfomation *)row cartypeId] == element.cartypeId)
                                     {
                                         addFlag = NO;
                                         break;
                                     }
                                 }
                             }
                             if (addFlag)
                             {
                                 CartypeInfomation * item = [[CartypeInfomation alloc] init];
                                 item.cartypeId = element.cartypeId;
                                 item.cartypeName = element.cartypeName;
                                 
                                 if (item)
                                 {
                                     [data addObject:item];
                                 }
                             }
                             //end
                         }
                     }];
                }
            }
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kGetCarTypeResponse];
            [tcpResponse setResponseData:[[RvcData shared] dataObjWithMethod:Res_CarType]];
            [[RvcData shared] removeDataObjForMethod:Res_CarType];
            rtnObject = tcpResponse;
            break;
        }
        case Res_CarBand:{
            GetCarBandRes * res = [GetCarBandRes parseFromData:data];
            * sid = res.sid;
            
            for (CarBandInfo * element in res.carBandGroupList) {
                if (element) {
                    [[RvcData shared] appendCacheWithMethod:Res_CarBand useBlock:^(id cache, NSError *error)
                     {
                         if ([cache isKindOfClass:[NSMutableArray class]])
                         {
                             NSMutableArray *data = (NSMutableArray *)cache;
                             
                             BOOL addFlag = YES;
                             //begin:code
                             if (data && data.count > 0)
                             {
                                 for (id row in data)
                                 {
                                     if ([(CarBandInfomation*)row bandId] == element.bandId)
                                     {
                                         addFlag = NO;
                                         break;
                                     }
                                 }
                             }
                             if (addFlag)
                             {
                                 CarBandInfomation * item = [[CarBandInfomation alloc] init];
                                 item.bandId = element.bandId;
                                 item.bandName = element.bandName;
                                 item.sequ = element.sequ;
                                 
                                 if (item)
                                 {
                                     [data addObject:item];
                                 }
                             }
                             //end
                         }
                     }];
                }
            }
            
            TcpResponse *tcpResponse = [TcpResponse response];
            [tcpResponse setSessionID:res.sid];
            [tcpResponse setRetCode:res.retCode];
            [tcpResponse setPrototype:kPrototypePost];
            [tcpResponse setTag:kGetCarBandResponse];
            [tcpResponse setResponseData:[[RvcData shared] dataObjWithMethod:Res_CarBand]];
            [[RvcData shared] removeDataObjForMethod:Res_CarBand];
            rtnObject = tcpResponse;
            break;
        }
    }
    return rtnObject;
}

@end
