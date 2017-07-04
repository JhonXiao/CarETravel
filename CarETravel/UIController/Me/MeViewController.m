//
//  MeViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/4.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "MeViewController.h"
#import "OrderViewController.h"
#import "UIWaitView.h"
#import "GcdNetSocket.h"
#import "MyOrderViewController.h"
#import "RvcNetWork.h"
#import "DataViewController.h"
#import "UICode.h"
#import "Config.h"
#import "SortOrderViewController.h"
#import "InformModifyViewController.h"
#import "ModifyPwdViewController.h"
#import "CustomServiceVC.h"

@interface MeViewController ()<NetSocketDelegate>{
    double yue;
}
@property (weak, nonatomic) IBOutlet UIButton *touXiangBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (weak, nonatomic) IBOutlet UILabel *currentYuELb;
@property (weak, nonatomic) IBOutlet UIButton *waitPayBtn;
- (IBAction)waitPayAction:(id)sender;
- (IBAction)messageMeAction:(id)sender;
- (IBAction)aboutBtnAction:(id)sender;
- (IBAction)loginOutAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *licensePlateLb;
- (IBAction)licensePlateAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *balanceLb;
- (IBAction)lookAllOrderAction:(id)sender;
- (IBAction)yxdAction:(id)sender;
- (IBAction)ywcAction:(id)sender;
- (IBAction)yqxAction:(id)sender;
- (IBAction)personDataAction:(id)sender;
- (IBAction)modifyPwdAction:(id)sender;
- (IBAction)contactCustomerAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginOutBottomCons;
@property (weak, nonatomic) IBOutlet UIButton *loginOutBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewMe;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"车E行";
    
    _touXiangBtn.layer.cornerRadius = _touXiangBtn.frame.size.width / 2;
    _touXiangBtn.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] getUserBalanceWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    RefineUserInfo * getReUserInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
    _licensePlateLb.text = getReUserInfo.carNo;
    _userNameLb.text = getReUserInfo.name;
    
    _scrollViewMe.showsVerticalScrollIndicator = NO;
    _scrollViewMe.bounces = NO;
    _scrollViewMe.contentSize = CGSizeMake(0, _loginOutBtn.frame.size.height + _loginOutBtn.frame.origin.y + 20);

    if (_loginOutBtn.frame.size.height + _loginOutBtn.frame.origin.y + 20 < kUIScreenHeight - 64 - 49 - 20) {
        _loginOutBottomCons.constant = kUIScreenHeight - 64 - 49 - 20 - _loginOutBtn.frame.size.height - _loginOutBtn.frame.origin.y;
//        _scrollViewMe.contentSize = CGSizeMake(0, _loginOutBtn.frame.size.height + _loginOutBtn.frame.origin.y + 20);
    }
    
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseUserBalanceList:data];
    });
}

- (void)parseUserBalanceList:(TcpResponse*)response{
    if (kGetUserBalanceResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    if (![data isKindOfClass:[NSNumber class]]) {
        return;
    }
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] hideLoading];
            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        });
        return;
    }
    yue = [data doubleValue];
    NSLog(@"yue:%f",yue);
    _balanceLb.text = [NSString stringWithFormat:@"%.2f",yue];
}

- (IBAction)waitPayAction:(id)sender {
    SortOrderViewController * sortVC = [[SortOrderViewController alloc] initWithNibName:@"SortOrderViewController" bundle:[NSBundle mainBundle]];
    sortVC.titleStr = @"待付款";
    [self.navigationController pushViewController:sortVC animated:YES];
}

- (IBAction)messageMeAction:(id)sender {
    [[UIWaitView sharedClient] showPrompt:@"功能建设中" withImage:@"tips_confirm"];
}

- (IBAction)aboutBtnAction:(id)sender {
    [[UIWaitView sharedClient] showPrompt:@"功能建设中" withImage:@"tips_confirm"];
}

- (IBAction)loginOutAction:(id)sender {
    [GcdNetSocket shared].isUserClose = YES;
    [UIData sharedClient].userClose = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[GcdNetSocket shared] disconnect];
}
- (IBAction)licensePlateAction:(id)sender {
}
- (IBAction)lookAllOrderAction:(id)sender {
    MyOrderViewController * myOrderVC = [[MyOrderViewController alloc] initWithNibName:@"MyOrderViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:myOrderVC animated:YES];
}

- (IBAction)yxdAction:(id)sender {
    SortOrderViewController * sortVC = [[SortOrderViewController alloc] initWithNibName:@"SortOrderViewController" bundle:[NSBundle mainBundle]];
    sortVC.titleStr = @"已下单";
    [self.navigationController pushViewController:sortVC animated:YES];
}

- (IBAction)ywcAction:(id)sender {
    SortOrderViewController * sortVC = [[SortOrderViewController alloc] initWithNibName:@"SortOrderViewController" bundle:[NSBundle mainBundle]];
    sortVC.titleStr = @"已完成";
    [self.navigationController pushViewController:sortVC animated:YES];
}

- (IBAction)yqxAction:(id)sender {
    SortOrderViewController * sortVC = [[SortOrderViewController alloc] initWithNibName:@"SortOrderViewController" bundle:[NSBundle mainBundle]];
    sortVC.titleStr = @"已取消";
    [self.navigationController pushViewController:sortVC animated:YES];
}

- (IBAction)personDataAction:(id)sender {

}

- (IBAction)modifyPwdAction:(id)sender {
    ModifyPwdViewController * modifyPwdVC = [[ModifyPwdViewController alloc] initWithNibName:@"ModifyPwdViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:modifyPwdVC animated:YES];
}

- (IBAction)contactCustomerAction:(id)sender {
    CustomServiceVC * customSerVC = [[CustomServiceVC alloc] initWithNibName:@"CustomServiceVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:customSerVC animated:YES];
}

@end
