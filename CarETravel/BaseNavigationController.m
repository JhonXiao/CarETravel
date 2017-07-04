//
//  BaseNavigationController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/3.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

+ (void)initialize{
    //设置导航条背景颜色
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:31.0/255 green:132.0/255 blue:254.0/255 alpha:1.0]];
    //设置导航条是否透明
        [[UINavigationBar appearance] setTranslucent:NO];
    //设置导航条内容的颜色
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //设置状态栏样式
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
        [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                NSFontAttributeName :           [UIFont systemFontOfSize:18],
                                                                NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }];
    
}

//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

@end
