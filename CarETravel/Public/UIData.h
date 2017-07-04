//
//  UIData.h
//  NetClient
//
//  Created by sunrise on 14-3-7.
//  Copyright (c) 2014年 com.sunrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TcpResponse.h"

@interface UIData : NSObject {
    NSMutableArray *theCacheQueue;
    NSMutableArray *theUICacheQueue;
    NSMutableDictionary *theDataMap;
}

@property (nonatomic, assign) int32_t loginID;
@property (nonatomic, assign) int32_t userID;
@property (nonatomic, assign) int32_t bankID;
@property (nonatomic, assign) int32_t userType;
@property (nonatomic, assign) int32_t memberID;
@property (nonatomic, assign) int32_t customerID;
@property (nonatomic, assign) int64_t loginTime;
@property (nonatomic, assign) int32_t loginVCStatus;//1,表示是有注册页面退回，默认为0-表示启动进入
@property(nonatomic,  assign) BOOL userClose;//是否是用户主动断开连接，默认为NO

- (id)init;

+ (UIData *)sharedClient;

- (void)append:(id)data withKey:(NSString *)key;
- (id)dataObjWithKey:(NSString *)key;
- (void)removeDataObjForKey:(NSString *)key;
- (void)append:(id)data withMethod:(int)method;
- (id)dataObjWithMethod:(int)method;

- (void)appendCacheWithMethod:(int)method useBlock:(void (^)(id cache, NSError *error))block;
- (void)dataCacheClear;
- (void)appendCacheWithKey:(NSString *)key useBlock:(void (^)(id cache, NSError *error))block;
- (void)dataUICacheClear;

- (void)clear;
- (void)clearAll;

//- (CommodityInfo *)commodityWithCommodityID:(NSInteger)comID;
//- (NSArray *)allNewCommodities;
//- (NSArray *)allCommodities;

@end


