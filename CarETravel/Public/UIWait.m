//
//  UIWait.m
//  NetClient
//
//  Created by sunrise on 14-3-20.
//  Copyright (c) 2014年 com.sunrise. All rights reserved.
//

#import "UIWait.h"

@implementation UIWait
{
    MBProgressHUD *HUD;
}

+ (UIWait *)sharedClient {
    __strong static UIWait *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UIWait alloc] init];
    });
    
    return _sharedClient;
}

#pragma mark - ProgressHUD releated
- (void)showLoading:(NSString *)text detailText:(NSString *)detailtext{
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        HUD.labelText     = text;
        HUD.graceTime     = 0.0;
        HUD.minShowTime   = 0.0;
        HUD.labelFont = [UIFont systemFontOfSize:16];//修改风火轮的提示字体大小
        HUD.color         = [UIColor colorWithRed:0.357 green:0.263 blue:0.129 alpha:1.0f];
        HUD.detailsLabelText = detailtext;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:14];
    }
}

- (void)showLoading:(NSString *)text {
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        HUD.labelText     = text;
        HUD.graceTime     = 0.0;
        HUD.minShowTime   = 0.0;
        HUD.labelFont = [UIFont systemFontOfSize:16];//修改风火轮的提示字体大小
//        HUD.color         = [UIColor colorWithRed:0.357 green:0.263 blue:0.129 alpha:1.0f];
        HUD.color         = [UIColor colorWithRed:31.0/255 green:132.0/255 blue:254.0/255 alpha:1.0f];
    }
    //[HUD hide:YES afterDelay:130];
}

- (void)showLoading:(NSString *)text afterDelay:(int)sec{
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        HUD.labelText     = text;
        HUD.graceTime     = 0.0;
        HUD.minShowTime   = 0.0;
        HUD.labelFont = [UIFont systemFontOfSize:16];//修改风火轮的提示字体大小
        HUD.color         = [UIColor colorWithRed:0.357 green:0.263 blue:0.129 alpha:1.0f];
    }
    [HUD hide:YES afterDelay:3];
}

-(void)showLoading:(NSString *)text onView:(UIView *)view
{
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.labelText     = text;
        HUD.graceTime     = 0.0;
        HUD.minShowTime   = 0.0;
        HUD.color         = [UIColor colorWithRed:0.357 green:0.263 blue:0.129 alpha:1.0f];
    }
}

- (void)hideLoading {
    [HUD hide:YES];
    if (HUD) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}

- (void)hideLoadingAfterDelay:(int)sec{
    [HUD hide:YES afterDelay:sec];
    if (HUD) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}

- (void)showAlert:(NSString *)text
{
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        HUD.labelText     = text;
        HUD.graceTime     = 0.0;
        HUD.minShowTime   = 0.0;
        HUD.color         = [UIColor colorWithRed:0.357 green:0.263 blue:0.129 alpha:1.0f];
    }
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

@end
