//
//  QuotesPush.h
//  YongWeiPan
//
//  Created by xiaoliwu on 2017/1/6.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QuotesPushDelegate <NSObject>

- (void)updatePushQuotationMethod;

@end

@interface QuotesPush : NSObject

@property (nonatomic, assign) id<QuotesPushDelegate>deleQuotes;
@property (nonatomic, strong) NSTimer * timerPush;
@property (nonatomic, assign) BOOL ifPush;

+ (QuotesPush *)quotesShared;

- (void)receviceQuotesInfo:(id)dataQuotes;

@end
