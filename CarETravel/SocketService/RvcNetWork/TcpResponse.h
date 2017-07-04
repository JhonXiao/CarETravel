//
//  TcpResponse.h
//  YongWeiPan
//
//  Created by revenco on 16/12/16.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

typedef NS_OPTIONS(NSUInteger, KeyTcpResponse) {
    kNoneResponse                    = 0,
    kLoginResponse                   = 1,
    kServiceResponse                 = 2,
    kPushExitResponse               =3,
    kPushBulletinResponse           =4,
    kUserOrderListResponse          =5,
    kUserOrderResponse              =6,
    kGetValidateCodeResponse        =7,
    kUserRegisterResponse           =8,
    kGetUserBalanceResponse         =9,
    kUserChargeResponse             =10,
    kGetUserInfoResponse            =11,
    kOrderBarcodeBindResponse       =12,
    kModifyUserInfoResponse         =13,
    kOrderPaymentResponse           =14,
    kGetCSInfoResponse              =15,
    kChangePasswdResponse           =16,
    kCheckScanCodeResponse          =17,
    kCancelOrderResponse            =18,
    kGetCarBandResponse             =19,
    kGetCarTypeResponse             =20
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TcpResponse Class Define
///////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface TcpResponse : NSObject
@property (nonatomic, readonly) NSUInteger tag;
@property (nonatomic, readonly) NSInteger retCode;
@property (nonatomic, readonly) prototype_t prototype;
@property (nonatomic, readonly) NSString* sessionID;
@property (nonatomic, readonly) id networker;
@property (nonatomic, readonly) id responseData;

+ (id)response;
- (void)setSessionID:(NSString*)sessionID;
- (void)setTag:(NSUInteger)tag;
- (void)setPrototype:(prototype_t)type;
- (void)setRetCode:(NSInteger)retCode;
- (void)setResponseData:(id)data;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 登录信息
///////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UserResInfo : NSObject
@property (nonatomic, assign) int32_t loginID;
@property (nonatomic, assign) int32_t userID;
@property (nonatomic, assign) int32_t userType;
@property (nonatomic, assign) int32_t memberID;
@property (nonatomic, retain) NSString* userName;
@end

@interface RefineUserInfo : NSObject
@property (nonatomic, assign) int32_t sex;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* carNo;
@property (nonatomic, retain) NSString* parkSlot;
@property (nonatomic, assign) int32_t parkType;//停车位类型：0-固定，1-临时
@property (nonatomic, assign) int32_t carType;//汽车型号
@property (nonatomic, retain) NSString * carColor;//汽车颜色，让用户自己输入
@property (nonatomic, retain) NSString * dispCarType;//汽车型号显示信息，例如： 奥迪A4,用户信息完善时，此项不用填
@end

@interface CSInfo : NSObject

@property (nonatomic, retain) NSString* csInfo;
@property (nonatomic, retain) NSString* version;

@end

//服务列表
@interface ServiceListInfo : NSObject
@property (nonatomic, assign) int32_t serviceId;
@property (nonatomic, retain) NSString * serviceCode;
@property (nonatomic, retain) NSString * serviceName;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) int32_t iconIndex;

@end

//用户订单列表查询
@interface UserOrderListInfo : NSObject
@property (nonatomic, assign) int64_t orderId;
@property (nonatomic, retain) NSString * orderNum;
@property (nonatomic, assign) int32_t serviceId;
@property (nonatomic, retain) NSString * serviceName;
@property (nonatomic, retain) NSString * serviceNum;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double disCount;
@property (nonatomic, assign) int32_t quantity;
@property (nonatomic, assign) double amount;
@property (nonatomic, assign) int32_t status;
@property (nonatomic, retain) NSString *createDate;
@property (nonatomic, retain) NSString *paidDate;
@property (nonatomic, retain) NSString *userBarCode;
@property (nonatomic, retain) NSString *userPickPwd;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, assign) int32_t  gridId;
@property (nonatomic, retain) NSString *gridInfo;

@end

//用户订购响应
@interface UserOrderInfo : NSObject
@property (nonatomic, assign) int32_t loginID;
@property (nonatomic, assign) int64_t orderId;
@end

//用户订单类
@interface OrderInfo : NSObject<NSCoding>
@property (nonatomic, assign) int32_t loginID;
@property (nonatomic, assign) int32_t serveId;
@property (nonatomic, assign) int32_t quantity;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double discount;
@property (nonatomic, assign) double amount;

//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

//账号密码保存
@interface AccountSave : NSObject
@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * pwd;
@end

//取消订单响应
@interface CancelOrderInfo : NSObject
@property (nonatomic, assign) int32_t loginId;
@property (nonatomic, assign) int32_t payType;
@property (nonatomic, retain) NSString * params;

@end

//快速扫描响应
@interface CheckScanCodeInfo : NSObject

@property (nonatomic, assign) int64_t orderId;
@property (nonatomic, assign) int32_t status;

@end

//汽车品牌响应
@interface CarBandInfomation : NSObject

@property (nonatomic, assign) int32_t bandId;
@property (nonatomic, retain) NSString * bandName;
@property (nonatomic, retain) NSString * sequ;//排序字母

@end

//汽车型号响应
@interface CartypeInfomation : NSObject

@property (nonatomic, assign) int32_t cartypeId;
@property (nonatomic, retain) NSString * cartypeName;

@end
