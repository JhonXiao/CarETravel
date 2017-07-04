//
//  MainViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/4.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "MallViewController.h"
#import "MeViewController.h"
#import "BaseNavigationController.h"
#import "ScanViewController.h"
#import "DataViewController.h"
#import "RechargeViewController.h"
#import "HWScanViewController.h"

@interface MainViewController (){
    UIBarButtonItem * setBarItem;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"顺事德养车";
    
    setBarItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(settingAction)];
    self.navigationItem.leftBarButtonItem = setBarItem;
    
//    UIBarButtonItem * messageBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_message"] style:UIBarButtonItemStylePlain target:self action:@selector(messageAction)];
//    
//    UIBarButtonItem * scanBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(scanAction)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:messageBarItem, scanBarItem, nil];
    
    HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]];
//    BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:homeVC];
//    MallViewController *mallVC = [[MallViewController alloc]initWithNibName:@"MallViewController" bundle:[NSBundle mainBundle]];
    MeViewController *MeVC = [[MeViewController alloc] initWithNibName:@"MeViewController" bundle:[NSBundle mainBundle]];
    ScanViewController * scanVC = [[ScanViewController alloc] init];
    scanVC.tabbarBlo = ^(NSUInteger sel) {
        if (sel == 0) {
            [self setSelectedIndex:0];
        }
    };
    
    self.viewControllers = @[homeVC,scanVC,MeVC];
    self.itemTitles = @[@"首页",@"扫一扫",@"我的"];//下边标题
    self.itemImages = @[@"icon_homegray",@"scan",@"icon_minegray"];//图标
    self.itemSelectedImages = @[@"icon_home",@"scan",@"icon_mine"];
    self.tintColor = [UIColor colorWithRed:31.0/255 green:132.0/255 blue:254.0/255 alpha:1.0];//选中后的颜色
    
//    [self setBadgeValue:@"10" withIndex:1];//设置角标
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
}

- (void)settingAction{
    DataViewController * dataVC = [[DataViewController alloc] initWithNibName:@"DataViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:dataVC animated:YES];
}

- (void)messageAction{
    RechargeViewController * rechangeVC = [[RechargeViewController alloc] initWithNibName:@"RechargeViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:rechangeVC animated:YES];
}

- (void)scanAction{
    HWScanViewController * hwScanVC = [[HWScanViewController alloc] init];
    [self.navigationController pushViewController:hwScanVC animated:YES];
}

- (void)notificationHideLeftNaviBar:(BOOL)st{
    if(st){
        [self.navigationItem setLeftBarButtonItem:nil];
    }else{
        [self.navigationItem setLeftBarButtonItem:setBarItem];
    }
}

@end
