//
//  TlsSocketDelegate.h
//  YongWeiPan
//
//  Created by revenco on 16/12/16.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GcdNetSocket;
@protocol TlsSocketDelegate <NSObject>

@optional
- (void)tlsSocketDidExchangeKeySuccess:(BOOL)res;
- (void)tlsSocketDidConnect:(GcdNetSocket *)client;
- (void)tlsSocketDidDisconnect:(GcdNetSocket *)client;
- (void)tlsSocketDidSendTimeOut:(GcdNetSocket *)client;
- (void)tlsSocketDidSendTimeOut:(GcdNetSocket *)client withCmd:(int)cmd;
- (void)tlsSocketDidSocketConnectTimeOut:(GcdNetSocket *)client;
- (void)tlsSocket:(int)method didReceivedData:(id)data;
- (void)tlsSocket:(int)method didPushData:(id)data;

@end
