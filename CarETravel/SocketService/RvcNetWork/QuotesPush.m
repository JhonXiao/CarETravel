//
//  QuotesPush.m
//  YongWeiPan
//
//  Created by xiaoliwu on 2017/1/6.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "QuotesPush.h"
#import "TcpResponse.h"
//#import "UIWaitView.h"
#import "Config.h"
#import "UICode.h"
#import "UIData.h"

@implementation QuotesPush
@synthesize timerPush;

+ (QuotesPush *)quotesShared
{
    static QuotesPush *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[QuotesPush alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _ifPush = NO;
        [self setTimer];
    }
    return self;
}

- (void)receviceQuotesInfo:(id)dataQuotes{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self postFromNetwork:dataQuotes];
    });
}

- (void)setTimer{
    // TODO:设置定时器
    if (self.timerPush != nil)
    {
        [self.timerPush invalidate];
        self.timerPush = nil;
    }
    self.timerPush = [NSTimer timerWithTimeInterval:1.5
                                             target:self
                                           selector:@selector(quotHDataViewOnTime)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timerPush forMode:NSDefaultRunLoopMode];
}

- (void)quotHDataViewOnTime{
    if (_ifPush) {
        if (_deleQuotes && [_deleQuotes respondsToSelector:@selector(updatePushQuotationMethod)]) {
            [_deleQuotes updatePushQuotationMethod];
        }
    }
}

#pragma mark - UIPostDelegate

- (void)postFromNetwork:(id)response
{
    //TODO: 后台推送(公告,行情,强制下线等)
    //    _outlineType = kOutlineNormal;
    
    TcpResponse *tcpResponse = response;
    id data = tcpResponse.responseData;
    
    switch (tcpResponse.tag)
    {
        case kPushExitResponse: // 清算强制下线
        {
            //TODO: 清算强制下线
            if (AF_FORCEOFF_CODE == tcpResponse.retCode)
            {
                NSString * message = @"报表已生成，请重新登录。";
//                [[UIWaitView sharedClient] showPopUpView:message withImage:@"alert.png" complement:^{
//                    exit(0);
//                }];
                
            }
            else
            {
                NSString * message = @"系统结算成功，在线用户强制下线。请重新登录。";
//                [[UIWaitView sharedClient] showPopUpView:message withImage:@"alert.png" complement:^{
//                    exit(0);
//                }];
            }
            break;
        }
        case kLoginResponse: // 重复登录，强制下线
        {
            //TODO:重复登录，强制下线
            if ([data isKindOfClass:[UserResInfo class]])
            {
                if (FORCEOFF_CODE == tcpResponse.retCode)
                {
                    NSString *message = [[UICode sharedClient] messageWithCode:tcpResponse.retCode];
//                    [[UIWaitView sharedClient] showPopUpView:message withImage:@"alert.png" complement:^{
//                        exit(0);
//                    }];
                }
            }
            break;
        }
        case kPushBulletinResponse: // 公告
        {
//            //TODO:公告推送
//            if ([data isKindOfClass:[BulletinInfo class]]) {
//                BulletinInfo *pushData = data;
//                NSString *noticeContent = [NSString stringWithFormat:@"%@",pushData.bulletinContent];
//                int32_t BulletinType = pushData.bulletinType;
//                //               1130010为限价单成交
//                
//                if (noticeContent && ![@"" isEqualToString:noticeContent])
//                {
//                    //                    AudioServicesPlaySystemSound(1000);// 系统音效
//                    //                    AudioServicesDisposeSystemSoundID(1000);// 系统音效停止
//                    //                    [self noticeHomeDataView];
//                }
//            }
            break;
        }
//        case kPushQuoteResponse://推送商品的行情数据
//        {
//            //TODO: 推送商品的行情数据
//            if ([data isKindOfClass:[QuoteDataPush class]])
//            {
//                [self parseQuotePushData:data];
//            }
//            break;
//        }
    }
}

@end
