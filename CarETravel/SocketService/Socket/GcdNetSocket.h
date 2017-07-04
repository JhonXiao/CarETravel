//
//  GcdNetSocket.h
//  YongWeiPan
//
//  Created by revenco on 16/12/14.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "IoPacket.h"
#import "TlsSocketDelegate.h"
#import "RvcNetWork.h"
#import "UIData.h"
#import "TcpResponse.h"

@interface GcdNetSocket : NSObject

@property(nonatomic,retain) NSDictionary* cerSSLSettings;
@property(nonatomic,assign) id<TlsSocketDelegate> delegate;
@property(nonatomic,assign) NSInteger askTimeOutWait;
@property(nonatomic,assign) NSInteger askTimeOutLimit;
@property(nonatomic,assign) NSInteger socketTimeOutWait;
@property(nonatomic,assign) NSInteger socketTimeOutCount;
@property(nonatomic,assign) NSInteger socketTimeOutLimit;
@property(nonatomic,assign) NSInteger socketTimeTimeout;
@property(nonatomic,retain) NSMutableArray *cmdFilterQueue;
@property(nonatomic,assign) BOOL isUserClose;//是否是用户主动断开连接，默认为NO

+ (GcdNetSocket *)shared;

- (void)ipv6Connect;
- (void)disconnect;
- (void)sendWithUI:(IoPacket *)data;

@end
