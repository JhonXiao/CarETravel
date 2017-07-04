//
//  RegisterVC.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/14.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "RegisterVC.h"
#import "UIWaitView.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "Config.h"

@interface RegisterVC ()<NetSocketDelegate>{
    NSString *codeRet;
}
@property (weak, nonatomic) IBOutlet UITextField *mobileTf;
@property (weak, nonatomic) IBOutlet UITextField *pwdTf;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTf;
@property (weak, nonatomic) IBOutlet UITextField *codeTf;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)registerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
- (IBAction)getCodeAction:(id)sender;

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"注册";
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backLoginAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    [RvcNetWork shared].response = self;
    [self UIInit];
}

- (void)backLoginAction{
    [UIData sharedClient].loginVCStatus = 1;
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)UIInit{
//    _getCodeBtn.layer.cornerRadius = 5.0;
//    _getCodeBtn.clipsToBounds = YES;
    _registerBtn.layer.cornerRadius = 5.0;
    _registerBtn.clipsToBounds = YES;
}

- (BOOL)checkPhoneNumberFomart{
    if (_mobileTf.text.length != 11) {
        [[UIWaitView sharedClient] showPrompt:@"手机号必须为11位" withImage:@"alert"];
        return NO;
    }
    return YES;
}

- (void)hiddenKeyboard{
    [_mobileTf resignFirstResponder];
    [_pwdTf resignFirstResponder];
    [_codeTf resignFirstResponder];
    [_confirmPwdTf resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hiddenKeyboard];
}

- (BOOL)checkPwdFormat{
    if (_pwdTf.text.length < 8) {
        [[UIWaitView sharedClient] showPrompt:@"密码至少8位" withImage:@"alert"];
        return NO;
    }
    if (_codeTf.text.length == 0) {
        [[UIWaitView sharedClient] showPrompt:@"请输入验证码" withImage:@"alert"];
        return NO;
    }
    if (![_pwdTf.text isEqualToString:_confirmPwdTf.text]) {
        [[UIWaitView sharedClient] showPrompt:@"两次输入的密码不一致" withImage:@"alert"];
        return NO;
    }
    if ([_pwdTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPopUpView:@"请输入密码" withImage:@"alert" complement:^{
            
        }];
        return NO;
    }
    return YES;
}

- (IBAction)getCodeAction:(id)sender {
    if ([self checkPhoneNumberFomart]) {
        [[RvcNetWork shared] getValidateCodeWithPhoneNum:_mobileTf.text sessionID:[[RvcNetWork shared] nextSessionID]];
    }
}

- (IBAction)registerAction:(id)sender {
    if ([self checkPwdFormat]) {
        [[RvcNetWork shared] registerWithPhoneNumber:_mobileTf.text withLoginPwd:_pwdTf.text withValidateCode:_codeTf.text withSessionID:[[RvcNetWork shared] nextSessionID]];
    }
//    [self checkPhoneNumberFomart];
    [self hiddenKeyboard];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseValidateCodeResponse:data];
        [self parseRegisterResponse:data];
    });
}
//13533364425

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
    NSLog(@"codeRet:%@",codeRet);
//    _codeTf.text = codeRet;
}

- (void)parseRegisterResponse:(TcpResponse*)response{
    if (kUserRegisterResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
//    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
//    if (![kParseRetCodeOK isEqualToString:message]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
//        });
//        return;
//    }

    [[UIWaitView sharedClient] showPrompt:data withImage:@"success"];
}

@end
