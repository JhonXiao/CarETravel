//
//  UIWait.h
//  NetClient
//
//  Created by sunrise on 14-3-20.
//  Copyright (c) 2014年 com.sunrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface UIWait : NSObject

+ (UIWait *)sharedClient;

- (void)showLoading:(NSString *)text;
- (void)showLoading:(NSString *)text afterDelay:(int)sec;
- (void)showLoading:(NSString *)text onView:(UIView *)view;
- (void)showLoading:(NSString *)text detailText:(NSString *)detailtext;
- (void)hideLoading;
- (void)hideLoadingAfterDelay:(int)sec;

- (void)showAlert:(NSString *)text;

@end
