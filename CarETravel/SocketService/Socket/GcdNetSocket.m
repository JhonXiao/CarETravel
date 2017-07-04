//
//  GcdNetSocket.m
//  YongWeiPan
//
//  Created by revenco on 16/12/14.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#define TAG_RESPONSE_BODY   1
#define TAG_RESPONSE_HEADER 111

#import "GcdNetSocket.h"
#import "Utility_Protected.h"
#import "IoPacket.h"
#import "NetSocketHelper.h"
#import "RvcHeader.h"
#import "Etravel.pb.h"
#import "UIWaitView.h"
//#import "LoginManager.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SendDataPacket
///////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SendDataPacket : NSObject
@property (nonatomic, assign) BOOL sended;
@property (nonatomic, retain) NSString *sid;
@property (nonatomic, assign) long last_send_time;
@property (nonatomic, retain) IoPacket *sendData;
@property (nonatomic, assign) int cmdCommand;
+ (id)packet;
@end

@implementation SendDataPacket
@synthesize sid, sendData, last_send_time,cmdCommand;
+ (id)packet
{
    SendDataPacket *obj = [[[self class] alloc] init];
    return obj;
}

@end

@interface GcdNetSocket(){
    NSMutableData *netRecvData;
    NSMutableArray *sendQueue;
    NSMutableDictionary *reSendSidCount;
    NSTimer *socketTimer;
    
    //TODO: ipv6连接需要的对象
    NSDictionary *_PBMessageClassNameDict;
    GCDAsyncSocket *_clientSocket;
    dispatch_queue_t _socketQueue;
    dispatch_queue_t _sendSocketQueue;
    NSDictionary *_tlsSettings;
    NSTimer *_heartBeartTimer;
    BOOL _exchangeOK;
    BOOL _exchangeCheckOK;
    NSMutableArray * serviceHostIP;
    NSMutableArray * servicePort;
    BOOL isReConnect;//是否是断线重连
}

@end

@implementation GcdNetSocket
@synthesize cerSSLSettings, delegate;

+ (GcdNetSocket *)shared
{
    static GcdNetSocket *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GcdNetSocket alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        netRecvData                 = [[NSMutableData alloc] init];
        sendQueue                   = [[NSMutableArray alloc] init];
        reSendSidCount              = [[NSMutableDictionary alloc] init];
        _isUserClose                = NO;
        self.askTimeOutWait         = 20;  //超时时长
        self.askTimeOutLimit        = 10;  //超时重发次数
        self.socketTimeTimeout      = 5;   //SOCKET连接超时时长
        self.socketTimeOutWait      = 0;   //SOCKET等待时间点
        self.socketTimeOutLimit     = 2;   //SOCKET连接超时次数
        self.socketTimeOutCount     = 0;   //SOCKET连接次数统计
        NSMutableArray *array = [NSMutableArray arrayWithObjects:
                                 [NSNumber numberWithInteger:Res_exchangeKey],
                                 [NSNumber numberWithInteger:Res_exchangeCheckKey],
                                 [NSNumber numberWithInteger:Res_HeartBeat],nil];
        [self setCmdFilterQueue:array];
        isReConnect = NO;
    }
    return self;
}

#pragma mark  兼容ipv6的代码
- (void)ipv6Connect
{
    if (!_clientSocket){
        _socketQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _clientSocket.IPv4PreferredOverIPv6 = NO;
    }
    
    if (_clientSocket.isConnected) {
        NSLog(@"_clientSocket__isConnnected");
        [self.delegate tlsSocketDidConnect:nil];
        return;
    }
    
    NSError *error;
//    hostIp = @"120.25.125.81";
    NSString * hostIp = @"120.25.214.233";
    hostIp = @"120.25.125.81";
    NSInteger port = 9006;
//    port = 9004;//开发端口
    [_clientSocket connectToHost:hostIp onPort:port withTimeout:-1 error:&error];
    if (error)
        NSLog(@"connect_error:%@",error);
}

- (void)disconnect {
    isReConnect = YES;
    [_clientSocket disconnect];
    [[NetSocketHelper shared] changeExChangeState:NO];
}

#pragma mark - GCDAsyncSocket代理方法

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"RRa__%08lX",(long)tag);
    if (tag == TAG_RESPONSE_HEADER) {
        [self parseResponseHeaderData:data];
        return;
    }
    
    data = [Utility decryptUseDES:data key:[Utility getDESKey]];
    switch (tag) {
        case Res_exchangeKey: {
            
            ExChangeKeyRes *res = [ExChangeKeyRes parseFromData:data];
            if(99999 == res.retCode){
                [Utility exchangeKeyOK:res.p withG:res.g withPubKey:res.svrpubkey];
                _exchangeOK = YES;
                NSLog(@"_exchangeOK__%d",_exchangeOK);
            }
            if (_exchangeOK) {
                [self sendExchangeCheckKey:0];
            } else {
                [self disconnect];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate tlsSocketDidSocketConnectTimeOut:nil];
                });
                return;
            }
            
            break;
        }
        case Res_exchangeCheckKey:{
            ExChangeCheckKeyRes *res = [ExChangeCheckKeyRes parseFromData:data];
            if(res.checkResult == 1){
                [Utility exchangeKeyCheckOK];
                _exchangeCheckOK = YES;
                NSLog(@"_exchangeCheckOK");
                [self.delegate tlsSocketDidConnect:nil];
            }else
            {
                _exchangeOK = NO;
            }
            if (_exchangeCheckOK) {
//                [self.delegate tlsSocketDidConnect:nil];
                [self heartBeat];
//                [self scanQueueCheckTimeout];
                [self startNSTimer];
            } else {
                [self disconnect];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate tlsSocketDidSocketConnectTimeOut:nil];
                });
                return;
            }
            
            break;
        }
            
        case Res_HeartBeat:
            break;
            
        default:
            [self parseDataWithCmd:tag withBody:data];
            break;
    }
    
    [_clientSocket readDataToLength:sizeof(header_t) withTimeout:-1 tag:TAG_RESPONSE_HEADER];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"GCDsocket:%@ didSecure",sock);
    [Utility genarateDefaultKey];
    [_clientSocket readDataToLength:sizeof(header_t) withTimeout:-1 tag:TAG_RESPONSE_HEADER];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self startNSTimer];
        if(_clientSocket.isConnected) [self sendExchangeKey];
    });
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"GCDsocket:%@ didConnectToHost:%@ port:%d",sock,host,port);
    _isUserClose = NO;
    [UIData sharedClient].userClose = NO;
    [_clientSocket startTLS:[self loadSSLSettings]];
//    if(delegate && [delegate respondsToSelector:@selector(tlsSocketDidConnect:)])
//    {
//        [delegate tlsSocketDidConnect:self];
//    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"GCDsocket:%p didDisconnect withError:%@",sock,err);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"userClose:%d",[UIData sharedClient].userClose);
        if ([UIData sharedClient].userClose) {
            return;
        }
        [[UIWaitView sharedClient] showPopUpView:@"网络连接已断开,请检查网络连接" withImage:@"alert" complement:^{
            [[GcdNetSocket shared] ipv6Connect];
        }];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate tlsSocketDidDisconnect:nil];
    });
    if (err.code == 51) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[UIWaitView sharedClient] showCanSelectPrompt:@"网络连接已断开,请检查网络连接" withImage:@"alert" withItem:@"否" withItem2:@"是"];
//            __weak UIWaitView * wselfWait = [UIWaitView sharedClient];
//            wselfWait.okSelBlo = ^(NSInteger sel){
//                if (sel == 2) {
//                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                    if ([[UIApplication sharedApplication] canOpenURL:url])
//                    {
//                        [[UIApplication sharedApplication] openURL:url];
//                    }
//                    [self performSelector:@selector(methodReConnect) withObject:nil afterDelay:2.0];
//                }
//            };
//            [LoginManager loginShared].block(FIMLoginOperType_Beat,YES);
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [[UIWaitView sharedClient] showCanSelectPrompt:@"与后台服务连接已断开,是否重新连接？" withImage:@"alert" withItem:@"否" withItem2:@"是"];
//            __weak UIWaitView * wselfWait = [UIWaitView sharedClient];
//            wselfWait.okSelBlo = ^(NSInteger sel){
//                if (sel == 2) {
//                    [self disconnect];
//                    [[UIWaitView sharedClient] hideCanSelectPromptView];
//                    [[GcdNetSocket shared] ipv6Connect];
////                    [[UIWaitView sharedClient] showLoading:@"与服务器建立连接中" withImage:@"tips_confirm"];
////                    [LoginManager loginShared].reConnect = YES;
////                    [[LoginManager loginShared] sendLoginRequest];
//                }
//            };
//            [[UIWaitView sharedClient] showBlockCanSelectPrompt:@"与后台服务连接已断开,是否重新连接？" withImage:@"alert" withItem:@"是" withItem2:@"否" complement:^(NSInteger sel) {
//                if (sel == 0) {
//                    [self disconnect];
//                    [[UIWaitView sharedClient] hideCanSelectPromptView];
//                    [[GcdNetSocket shared] ipv6Connect];
//                }else if (sel == 1){
//                    
//                }
//            }];
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    completionHandler(YES);
    NSLog(@"________________________didReceiveTrust");
}

- (void)methodReConnect{
//    [[UIWaitView sharedClient] showCanSelectPrompt:@"与后台服务连接已断开,是否重新连接？" withImage:@"alert" withItem:@"否" withItem2:@"是"];
//    __weak UIWaitView * wselfWait = [UIWaitView sharedClient];
//    wselfWait.okSelBlo = ^(NSInteger sel){
//        if (sel == 2) {
//            [self disconnect];
//            [[UIWaitView sharedClient] hideCanSelectPromptView];
//            [LoginManager loginShared].reConnect = YES;
//            [[LoginManager loginShared] sendLoginRequest];
//        }
//    };
}

#pragma mark - HeartBeat

- (void)heartBeat {
    if (_heartBeartTimer) {
        [_heartBeartTimer invalidate];
        _heartBeartTimer = nil;
    }
    
    _heartBeartTimer = [NSTimer timerWithTimeInterval:20 target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_heartBeartTimer forMode:NSRunLoopCommonModes];
}

- (void)sendHeartBeat {
//    NSInteger interval = [Utility getCurrentTimeOfSecond];
//    IoPacket *packet = [BCCore packetWithSendHeartbeat:0];
    IoPacket *packet = [[NetSocketHelper shared] corePacketWithSendHeartbeat:0];
    NSLog(@"ipv6_send_____%08X__%@",packet.Header.command,packet.Sid);
    NSData *dataToSend = [self encode:packet];
    if (_clientSocket.isConnected) {
        [_clientSocket writeData:dataToSend withTimeout:-1 tag:Req_HeartBeat];
    }
}

- (void)sendExchangeKey {
    if (_clientSocket.isConnected) {
//        IoPacket *packet = [BCCore packetWithSendExchangeKey:0];
        NSInteger interval = [Utility getCurrentTimeOfSecond];
        IoPacket *packet = [[NetSocketHelper shared] corePacketWithSendExchangeKey:interval];
        NSData   *data   = [self encode:packet];
        [_clientSocket writeData:data withTimeout:-1 tag:Req_exchangeKey];
        
    } else {
        [self disconnect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate tlsSocketDidSocketConnectTimeOut:nil];
        });
    }
}

- (void)sendExchangeCheckKey:(NSInteger)interval {
    if (_clientSocket.isConnected) {
//        IoPacket *packet = [BCCore packetWithSendExchangeCheckKey:0];
        IoPacket *packet = [[NetSocketHelper shared] corePacketWithSendExchangeCheckKey:0];
        NSData   *data = [self encode:packet];
        [_clientSocket writeData:data withTimeout:-1 tag:Req_exchangeCheckKey];
        
    } else {
        [self disconnect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate tlsSocketDidSocketConnectTimeOut:nil];
        });
    }
}

#pragma mark - NSTimer Releated

- (void)runningTime
{
    NSInteger interval = [Utility getCurrentTimeOfSecond];
    
    [self scanQueue:interval];
    //在无网络情况下，不发送自动登录请求
    if ([Utility netWorkReachability]) {
//        if(_clientSocket.isConnected) [self sendHeartbeat:interval];
        
//        if(_clientSocket.isConnected) [self sendExchangeKey:interval];
//        
//        if(_clientSocket.isConnected) [self sendExchangeCheckKey:interval];
    }
}

- (void)startNSTimer
{
    if (socketTimer != nil)
    {
        [socketTimer invalidate];
        socketTimer = nil;
    }
    
    socketTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(runningTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:socketTimer forMode:NSRunLoopCommonModes];
}

- (void)stopNSTimer
{
    if (socketTimer != nil)
    {
        [socketTimer invalidate];
        socketTimer = nil;
    }
}

#pragma requestQueue
- (void)addSidToQueue:(NSString *)sid withData:(IoPacket *)data
{
    @synchronized(sendQueue){
        SendDataPacket *tmp = [SendDataPacket packet];
        tmp.last_send_time = [Utility getCurrentTimeOfSecond];
        tmp.sendData = data;
        tmp.sid = sid;
        tmp.sended = NO;
        tmp.cmdCommand = data.Header.command;
        //        NSLog(@"sendPacket:%08X,sid:%@",tmp.cmdCommand,tmp.sid);
        for (int t = 0; t < sendQueue.count; t ++) {
            //TODO: 删除缓存的请求队列里相同的请求（根据命令字来判断）
            SendDataPacket * sendPacket = [sendQueue objectAtIndex:t];
            if (tmp.cmdCommand == sendPacket.cmdCommand) {
                [sendQueue removeObjectAtIndex:t];
            }
        }
        [sendQueue addObject:tmp];
        //        NSLog(@"sendPacket:%08X,sid:%@,count:%d",tmp.cmdCommand,tmp.sid,sendQueue.count);
    }
}

- (void)deleteQueueOfSid:(NSString *)sid
{
    @synchronized(sendQueue)
    {
        for (int i=0; i<sendQueue.count; i++)
        {
            SendDataPacket *tmp = [sendQueue objectAtIndex:i];
            NSString *nssid = tmp.sid;
            if( [nssid isEqualToString:sid] )
            {
                if (0<[sendQueue count] && i<[sendQueue count])
                {
                    [sendQueue removeObjectAtIndex:i];
                }
            }
        }
    }
}

- (void)scanQueue:(NSInteger)interval
{
    //发送包是否超时检查
    @synchronized(sendQueue)
    {
        for (int i=0; i<sendQueue.count; i++)
        {
            SendDataPacket *tmp = [sendQueue objectAtIndex:i];
            if(interval-tmp.last_send_time >= self.askTimeOutWait)
            {
                if (0<[sendQueue count] && i<[sendQueue count]){
                    [sendQueue removeObjectAtIndex:i];
                }
                
//                if (delegate && [delegate respondsToSelector:@selector(tlsSocketDidSendTimeOut:)])
//                {
//                    [delegate tlsSocketDidSendTimeOut:self];
//                }
//                if (delegate && [delegate respondsToSelector:@selector(tlsSocketDidSendTimeOut:withCmd:)]) {
//                    [delegate tlsSocketDidSendTimeOut:self withCmd:tmp.cmdCommand];
//                }
//                NSString *plist = [[NSBundle mainBundle] pathForResource:@"CommandCode" ofType:@"plist"];
//                NSDictionary* codeDict = [[NSDictionary alloc]initWithContentsOfFile:plist];
//                NSString *key = [NSString stringWithFormat:@"0X%08X",tmp.cmdCommand];
//                NSString * message = [codeDict objectForKey:key];
//                message = [message stringByAppendingString:@"超时"];
//                [[UIWaitView sharedClient] showPrompt:message withImage:@"alert"];
            }
        }
    }
}

- (void)sendHeartbeat:(NSInteger)interval
{
    IoPacket *packet = [[NetSocketHelper shared] corePacketWithSendHeartbeat:interval];
    if (packet) {
        [self send:packet];
    }
}

- (BOOL)isConnected {
    return _clientSocket.isConnected && _exchangeOK && _exchangeCheckOK;
}

#pragma mark Send Releadted

- (void)sendWithUI:(IoPacket *)data
{
    [self sendAgain:data];
}

- (void)send:(IoPacket *)data
{
    if (_clientSocket.isConnected) {
        NSData *dataTosend = [self encode:data];
        NSLog(@"ipv6_send_____%08X__%@",data.Header.command,data.Sid);
        [_clientSocket writeData:dataTosend withTimeout:-1 tag:data.Header.command];
    }
}

- (void)sendAgain:(IoPacket *)data
{
    if (self.isConnected) {
        [self addSidToQueue:data.Sid withData:data];
        NSData *dataToSend = [self encode:data];
        [_clientSocket writeData:dataToSend withTimeout:-1 tag:data.Header.command];
        NSLog(@"ipv6_sendAgain__%08X__%@", data.Header.command, data.Sid);
        
    } else {
//        [self timeoutWithpacket:data];
    }
}

#pragma mark 加密
- (NSData *)encode:(IoPacket *)ioPacket
{
    NSData * sendData = [[NetSocketHelper shared] coreEncryptSendData:ioPacket.Body];
    
    header_t head = ioPacket.Header;
    unsigned long allDataLen = sendData.length + sizeof(header_t);
    head.length = (int)allDataLen;
    
    head = [Utility htonlWithhead:head];
    
    NSMutableData* data = [NSMutableData data];
    
    [data appendBytes:&head length:sizeof(header_t)];
    [data appendData:sendData];
    
    return data;
}

#pragma mark SSL通信通道加密代码
- (NSDictionary*)loadSSLSettings{
    
    NSDictionary *settings = nil;
    CFTypeRef certs[2] = {[self getIdentityRef],
        CFArrayGetValueAtIndex([self getSecCertificateRefs], 0)};
    CFArrayRef certsArray = CFArrayCreate(NULL, (void *)certs, 2, NULL);
    
    settings = @{(__bridge id)kCFStreamSSLIsServer    : @(NO),
                 GCDAsyncSocketManuallyEvaluateTrust  : @(YES),
                 //               GCDAsyncSocketSSLProtocolVersionMin  : @(kSSLProtocol3),
                 //               GCDAsyncSocketSSLProtocolVersionMax  : @(kTLSProtocol12),
                 (__bridge id)kCFStreamSSLCertificates: CFBridgingRelease(certsArray)};
    
    return settings;
}
- (CFArrayRef)getSecCertificateRefs{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"cer"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef certCFData = (__bridge CFDataRef)certData;
    SecCertificateRef cert = NULL;
    cert = SecCertificateCreateWithData(NULL, certCFData);
    
    SecCertificateRef certArray[1] = { cert };
    CFArrayRef certs = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust = NULL;
    
    OSStatus status = SecTrustCreateWithCertificates(certs, myPolicy, &myTrust);
    
    if (myPolicy)
        CFRelease(myPolicy);
    if (myTrust){
        CFRelease(myTrust);
    }
    
    return status==noErr ? certs : NULL;
}
- (SecIdentityRef)getIdentityRef{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
    CFStringRef password = CFSTR("123456");
    
    SecIdentityRef myIdentity = NULL;
    SecTrustRef myTrust = NULL;
    OSStatus status = noErr;
    
    status = extractIdentityAndTrust(inPKCS12Data, &myIdentity, &myTrust, password);
    
    if (myTrust)
        CFRelease(myTrust);
    
    return status==noErr ? myIdentity : NULL;
}
OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust,
                                 CFStringRef keyPassword){
    OSStatus securityError = errSecSuccess;
    
    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { keyPassword };
    CFDictionaryRef optionsDictionary = NULL;
    optionsDictionary = CFDictionaryCreate(NULL, keys, values, (keyPassword ? 1 : 0), NULL, NULL);
    
    CFArrayRef items = NULL;
    securityError = SecPKCS12Import(inPKCS12Data,optionsDictionary,&items);
    
    if (securityError == noErr) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        
        const void *tempIdentity = NULL;
        tempIdentity =  CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)CFRetain(tempIdentity);
        
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *outTrust = (SecTrustRef)CFRetain(tempTrust);
    }
    
    if (optionsDictionary)
        CFRelease(optionsDictionary);
    if (items)
        CFRelease(items);
    
    return securityError;
}

#pragma mark 收到包解析
- (void)parseResponseHeaderData:(NSData *)data
{
    if (data.length != sizeof(header_t)) {
        NSLog(@"Read header error!");
        return;
    }
    
    header_t * header = malloc(sizeof(header_t));
    memcpy(header, [data bytes], sizeof(header_t));
    uint32_t * p = (uint32_t*)header;
    for (int i=0; i<8; i++,p++) {
        *p = ntohl(*p);
    }
    
    if (_clientSocket.isConnected) {
        [_clientSocket readDataToLength :(header->length-sizeof(header_t))
                             withTimeout:2
                                     tag:header->command];
    }
    
    free(header);
}

- (void)parseDataWithCmd:(int)cmd withBody:(NSData *)data {
    //解码
    NSString * sid = NULL;
    prototype_t protoType;
    id response = [[NetSocketHelper shared] coreParseWithCmd:cmd withData:data outDataWithSid:&sid outDataWithType:&protoType];
//#ifdef DEBUG_NB
    if (cmd!=0X02010001 && cmd!=0X02010003) {
        NSLog(@"RR__%08X__%@__%ld",cmd,sid,(long)((TcpResponse*)response).retCode);
    }
//#endif
    if(sid) {
        [self deleteQueueOfSid:sid];
    }
    
    if (!response) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (protoType) {
            case kPrototypePost:
                [self.delegate tlsSocket:cmd didReceivedData:response];
                break;
            case kPrototypePush:
                [self.delegate tlsSocket:cmd didPushData:response];
                break;
            default:
                break;
        }
    });
}

@end
