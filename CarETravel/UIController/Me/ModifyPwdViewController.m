//
//  ModifyPwdViewController.m
//  CarETravel
//
//  Created by yg on 2017/5/1.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ModifyPwdViewController.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "UIWaitView.h"
#import "Config.h"

@interface ModifyPwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nwPwdTf;

@property (weak, nonatomic) IBOutlet UITextField *originPwTf;
@property (weak, nonatomic) IBOutlet UITextField *nwPwdConfirmTf;
- (IBAction)okAction:(id)sender;


@end

@implementation ModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"修改密码";
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backMeAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    [RvcNetWork shared].response = self;
}

- (void)backMeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkTfData{
    if ([_originPwTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPopUpView:@"请输入原密码" withImage:@"alert" complement:^{
            
        }];
        return NO;
    }
    if ([_nwPwdTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPopUpView:@"请输入新密码" withImage:@"alert" complement:^{
            
        }];
        return NO;
    }
    if ([_nwPwdConfirmTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPopUpView:@"请输入新密码确认" withImage:@"alert" complement:^{
            
        }];
        return NO;
    }
    if (_nwPwdTf.text.length < 8) {
        [[UIWaitView sharedClient] showPrompt:@"新密码至少8位" withImage:@"alert"];
        return NO;
    }
    if (![_nwPwdTf.text isEqualToString:_nwPwdConfirmTf.text]) {
        [[UIWaitView sharedClient] showPrompt:@"两次输入的密码不一致" withImage:@"alert"];
        return NO;
    }
    return YES;
}

- (void)resginTf{
    [_originPwTf resignFirstResponder];
    [_nwPwdTf resignFirstResponder];
    [_nwPwdConfirmTf resignFirstResponder];
}

- (IBAction)okAction:(id)sender {
    if ([self checkTfData]) {
        [self resginTf];
        [[RvcNetWork shared] changePasswdWithLoginId:[UIData sharedClient].loginID withUserType:1 withOldPwd:_originPwTf.text withNewPwd:_nwPwdTf.text withSessionSid:[[RvcNetWork shared] nextSessionID]];
    }
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseChangePwdResponse:data];
    });
}

- (void)parseChangePwdResponse:(TcpResponse*)response{
    if (kChangePasswdResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] hideLoading];
            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        });
        return;
    }
    [[UIWaitView sharedClient] showPopUpView:@"密码修改成功" withImage:@"success" complement:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
