//
//  RegisterViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/8.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIWaitView.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "Config.h"

@interface RegisterViewController ()<NetSocketDelegate>{
    NSString * codeRet;
}
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneTf;
@property (weak, nonatomic) IBOutlet UITextField *pwdTf;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTf;
@property (weak, nonatomic) IBOutlet UITextField *codeTf;
- (IBAction)getCodeAction:(id)sender;
- (IBAction)registerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIView *mobileView;
@property (weak, nonatomic) IBOutlet UIView *pwdView;
@property (weak, nonatomic) IBOutlet UIView *confirmPwdView;
@property (weak, nonatomic) IBOutlet UIView *codeView;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"注册";
//    self.navigationItem.hidesBackButton = YES;
    
    [self UIInit];
}

- (void)UIInit{
    _getCodeBtn.layer.cornerRadius = 5.0;
    _getCodeBtn.clipsToBounds = YES;
    _registerBtn.layer.cornerRadius = 5.0;
    _registerBtn.clipsToBounds = YES;
    _mobileView.layer.cornerRadius = 5.0;
    _mobileView.clipsToBounds = YES;
    _pwdView.layer.cornerRadius = 5.0;
    _pwdView.clipsToBounds = YES;
    _confirmPwdView.layer.cornerRadius = 5.0;
    _confirmPwdView.clipsToBounds = YES;
    _codeView.layer.cornerRadius = 5.0;
    _codeView.clipsToBounds = YES;
}

- (void)checkPhoneNumberFomart{
    if (_mobilePhoneTf.text.length != 11) {
        [[UIWaitView sharedClient] showPrompt:@"手机号必须为11位" withImage:@"alert"];
        return;
    }
}

- (void)checkPwdFormat{
    if (_pwdTf.text.length < 8) {
        [[UIWaitView sharedClient] showPrompt:@"密码至少8位" withImage:@"alert"];
        return;
    }
    if (_codeTf.text.length == 0) {
        [[UIWaitView sharedClient] showPrompt:@"请输入验证码" withImage:@"alert"];
        return;
    }
    if (![_pwdTf.text isEqualToString:_confirmPwdTf.text]) {
        [[UIWaitView sharedClient] showPrompt:@"两次输入的密码不一致" withImage:@"alert"];
        return;
    }
    if ([_codeTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPrompt:@"请输入验证码" withImage:@"alert"];
        return;
    }
}

- (IBAction)getCodeAction:(id)sender {
    [self checkPhoneNumberFomart];
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] getValidateCodeWithPhoneNum:_mobilePhoneTf.text sessionID:[[RvcNetWork shared] nextSessionID]];
}

- (IBAction)registerAction:(id)sender {
    [self checkPhoneNumberFomart];
    [self checkPwdFormat];
    [[RvcNetWork shared] registerWithPhoneNumber:_mobilePhoneTf.text withLoginPwd:_pwdTf.text withValidateCode:_codeTf.text withSessionID:[[RvcNetWork shared] nextSessionID]];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseValidateCodeResponse:data];
        [self parseRegisterResponse:data];
    });
}

- (void)parseValidateCodeResponse:(TcpResponse*)response{
    if (kGetValidateCodeResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        });
        return;
    }
    codeRet = data;
}

- (void)parseRegisterResponse:(TcpResponse*)response{
    if (kUserRegisterResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        });
        return;
    }
    [[UIWaitView sharedClient] showPrompt:data withImage:@"error"];
}

@end
