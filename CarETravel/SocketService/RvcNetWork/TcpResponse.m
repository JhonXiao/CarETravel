//
//  TcpResponse.m
//  YongWeiPan
//
//  Created by revenco on 16/12/16.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import "TcpResponse.h"

@implementation TcpResponse

@synthesize tag = _tag;
@synthesize networker = _networker;
@synthesize responseData = _responseData;
@synthesize sessionID = _sessionID;
@synthesize retCode = _retCode;
@synthesize prototype = _prototype;
+ (id)response
{
    TcpResponse *obj = [[[self class] alloc] init];
    return obj;
}

- (void)setOwner:(id)owner
{
    _networker = owner;
}
- (void)setResponseData:(id)data
{
    _responseData = data;
}
- (void)setSessionID:(NSString*)sessionID
{
    _sessionID = sessionID;
}
- (void)setTag:(NSUInteger)tag
{
    _tag = tag;
}
- (void)setPrototype:(prototype_t)type
{
    _prototype = type;
}
- (void)setRetCode:(NSInteger)retCode
{
    _retCode = retCode;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 登录信息
///////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UserResInfo

@end

//服务列表
@implementation ServiceListInfo

@end

//用户订单列表查询
@implementation UserOrderListInfo

@end

//用户订购响应
@implementation UserOrderInfo

@end

//用户订单类
@implementation OrderInfo

- (instancetype)init{
    if (self == [super init]) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self == [super init]) {
        self.loginID = [aDecoder decodeIntForKey:@"loginID"];
        self.serveId = [aDecoder decodeIntForKey:@"serviceID"];
        self.quantity = [aDecoder decodeIntForKey:@"quantity"];
        self.price = [aDecoder decodeDoubleForKey:@"price"];
        self.discount = [aDecoder decodeDoubleForKey:@"discount"];
        self.amount = [aDecoder decodeDoubleForKey:@"amount"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSNumber numberWithInt:self.loginID] forKey:@"loginID"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.serveId] forKey:@"serviceID"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.quantity] forKey:@"quantity"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.price] forKey:@"price"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.discount] forKey:@"discount"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.amount] forKey:@"amount"];
}

@end

@implementation CSInfo

@end

@implementation RefineUserInfo

@end

@implementation AccountSave

@end

@implementation CancelOrderInfo

@end

@implementation CheckScanCodeInfo

@end

@implementation CarBandInfomation

@end

@implementation CartypeInfomation

@end
