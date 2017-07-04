//
//  LoginViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/3.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "LoginViewController.h"
#import "RvcNetWork.h"
#import "GcdNetSocket.h"
#import "MainViewController.h"
//#import "RegisterViewController.h"
#import "RegisterVC.h"
#import "UICode.h"
#import "UIWaitView.h"
#import "Config.h"
#import "UIWait.h"
#import "MemberNoticeVC.h"
#import "InformModifyViewController.h"

@interface LoginViewController ()<NetSocketDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    BOOL ifConnect;
    NSMutableArray * dataSourceRemeber;
}
@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *pwdTf;
- (IBAction)loginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIView *pwdView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
- (IBAction)registerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)switchAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchPwd;
@property (weak, nonatomic) IBOutlet UIButton *logoBtn;
@property (weak, nonatomic) IBOutlet UIButton *fogotPwdBtn;
- (IBAction)fogotPwdAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *remeberTb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remTbHeightCons;
- (IBAction)remAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *currentVerBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    ifConnect = NO;
    _userView.layer.cornerRadius = 5.0;
    _userView.clipsToBounds = YES;
    _userView.layer.borderColor =[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0].CGColor;
    _userView.layer.borderWidth = 2.0;
    
    _pwdView.layer.cornerRadius = 5.0;
    _pwdView.clipsToBounds = YES;
    _pwdView.layer.borderColor =[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0].CGColor;
    _pwdView.layer.borderWidth = 2.0;
    
    _loginBtn.layer.cornerRadius = 5.0;
    _loginBtn.clipsToBounds = YES;
    _registerBtn.layer.cornerRadius = 5.0;
    _registerBtn.clipsToBounds = YES;
    
//    _logoBtn.layer.cornerRadius = _logoBtn.frame.size.width / 2.0;
//    _logoBtn.clipsToBounds = YES;

    _accountTf.delegate = self;
    _pwdTf.delegate = self;
//    _accountTf.text = @"test001";
//    _pwdTf.text = @"123";
    [_pwdTf setSecureTextEntry:YES];
    _switchPwd.on = YES;
    
    dataSourceRemeber = [[NSMutableArray alloc] init];
    _remeberTb.delegate = self;
    _remeberTb.dataSource = self;
    _remeberTb.bounces = NO;
    _remeberTb.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSourceRemeber.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * strCell = @"cellIdentify";
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString * strAccGe = [dataSourceRemeber objectAtIndex:indexPath.row];
    cell.textLabel.text = [[strAccGe componentsSeparatedByString:@"|"] firstObject];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    AccountSave * accountSave = [dataSourceRemeber objectAtIndex:indexPath.row];
    NSString * strAcc = [dataSourceRemeber objectAtIndex:indexPath.row];
    _accountTf.text = [[strAcc componentsSeparatedByString:@"|"] firstObject];
    _pwdTf.text = [[strAcc componentsSeparatedByString:@"|"] lastObject];
    _remTbHeightCons.constant = 0.0;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyBoard];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 delay: 0.35 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
        
    } completion: ^(BOOL finished) {
        self.view.frame = CGRectMake(0, - 100, self.view.frame.size.width, self.view.frame.size.height + 164);
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if ([textField isEqual:_accountTf]) {
        _remTbHeightCons.constant = 0.0;
    }
    return YES;
}

- (void)hideKeyBoard{
    [_accountTf resignFirstResponder];
    [_pwdTf resignFirstResponder];
    [UIView animateWithDuration: 0.5 delay: 0.35 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
        
    } completion: ^(BOOL finished) {
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    [_currentVerBtn setTitle:[NSString stringWithFormat:@"当前版本号:%@",currentVersion] forState:UIControlStateNormal];
    
    [self checkVersion:@""];
    [RvcNetWork shared].response = self;
    if ([UIData sharedClient].loginVCStatus == 0) {
        [[GcdNetSocket shared] ipv6Connect];
//        [[UIWaitView sharedClient] showLoading:@"与服务器建立连接中" withImage:@"tips_confirm"];
        [[UIWait sharedClient] showLoading:@"连接服务器中，请稍后"];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [self hideKeyBoard];
}

#pragma mark --更新版本
- (void)checkVersion:(NSString *)newVersion{
    NSURL *url = [NSURL URLWithString:@"http://120.25.125.81/ios-update/iOSVersion.txt"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    //请求超时>5s
    if (!data || error) {
        return;
    }
    //版本已是最新
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *array = [response componentsSeparatedByString:@"|"];
    
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
    if ([currentVersion compare:[array objectAtIndex:0] options:NSNumericSearch] != NSOrderedAscending) {
        return;
    }
    
    NSString * downStr = @"https://www.pgyer.com/irau";
    NSURL * urlDown = [NSURL URLWithString:downStr];
    
    [[UIWaitView sharedClient ] showPopUpView:@"请下载最新APP版本,安装密码为123321" withImage:@"alert" complement:^{
        if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
            [[UIApplication sharedApplication] openURL:urlDown];
        }else{
            [[UIApplication sharedApplication] openURL:urlDown options:@{} completionHandler:^(BOOL success) {
                exit(0);
            }];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideKeyBoard];
}

- (void)netSocketClientDidConnected:(id)netSocket{
    dispatch_async(dispatch_get_main_queue(), ^{
        ifConnect = YES;
        [[UIWait sharedClient] hideLoading];
//        [[RvcNetWork shared] customerServiceQueryWithLoginID:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    });
}

- (void)netSocketClientDidClosed:(id)netSocket{
    ifConnect = NO;
    [[UIWaitView sharedClient] hideLoading];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseLoginResponse:data];
        [self parseUserInfo:data];
        [self parseCustomerServiceResponse:data];
    });
}

- (void)parseCustomerServiceResponse:(TcpResponse*)response{
    if (kGetCSInfoResponse != response.tag)
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
    CSInfo * infoCs = data;
//    NSString * verStr = infoCs.version;
//    [self checkVersion:[verStr componentsSeparatedByString:@"|"].firstObject];
    [[UIData sharedClient] append:infoCs withKey:@"kCustomerServiceInfoData"];
}

- (void)parseLoginResponse:(TcpResponse*)response{
    if (kLoginResponse != response.tag)
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
    [self historyAccountSave];
    _accountTf.text = @"";
    _pwdTf.text = @"";
    //查询用户资料
    [[RvcNetWork shared] queryUserDataWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
}

- (void)parseUserInfo:(TcpResponse*)response{
    if (kGetUserInfoResponse != response.tag)
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
    RefineUserInfo * reUserInfo = data;
    [[UIData sharedClient] append:reUserInfo withKey:@"kUserInfoData"];
    if (reUserInfo.carType == 0) {
        [[UIWaitView sharedClient] showBlockCanSelectPrompt:@"您尚未提供车型信息，系统将按照最高价格为您提供服务" withImage:@"alert" withItem:@"马上完善信息" withItem2:@"以后再说" complement:^(NSInteger sel) {
            if (sel == 0) {
                InformModifyViewController * informModifyVC = [[InformModifyViewController alloc] initWithNibName:@"InformModifyViewController" bundle:[NSBundle mainBundle]];
                informModifyVC.fromVC = 1;
                [self.navigationController pushViewController:informModifyVC animated:YES];
            }else if (sel == 1){
                NSLog(@"cancel");
                MainViewController * mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
                [self.navigationController pushViewController:mainVC animated:YES];
            }
        }];
    }else{
        MainViewController * mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:mainVC animated:YES];
    }
}

- (IBAction)loginAction:(id)sender {
    [self hideKeyBoard];
    if ([_accountTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPrompt:@"请输入手机号" withImage:@"alert"];
        return;
    }else if ([_pwdTf.text isEqualToString:@""]){
        [[UIWaitView sharedClient] showPrompt:@"请输入密码" withImage:@"alert"];
        return;
    }
    
    if (!ifConnect) {
        [[GcdNetSocket shared] ipv6Connect];
//        [[UIWaitView sharedClient] showLoading:@"与服务器建立连接中" withImage:@"tips_confirm"];
        [[UIWait sharedClient] showLoading:@"连接服务器中，请稍后"];
        [[RvcNetWork shared] doLogin:_accountTf.text withPassword:_pwdTf.text withUserType:1 withSessionID:[[RvcNetWork shared] nextSessionID]];
    }else{
        [[RvcNetWork shared] doLogin:_accountTf.text withPassword:_pwdTf.text withUserType:1 withSessionID:[[RvcNetWork shared] nextSessionID]];
    }
}

- (void)historyAccountSave{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    NSArray * saveArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccountRemArr"];
    if (saveArr) {
        [arr addObjectsFromArray:saveArr];
    }
    BOOL flag = NO;
    for (int i = 0; i < arr.count; i ++) {
        NSArray * arrAccStr = [[arr objectAtIndex:i] componentsSeparatedByString:@"|"];
        if ([[arrAccStr firstObject] isEqualToString:_accountTf.text]) {
            flag = YES;
            break;
        }
    }
    if (!flag) {
//        AccountSave * accSave = [[AccountSave alloc] init];
//        accSave.account = _accountTf.text;
//        accSave.pwd = _pwdTf.text;
        NSString * strAcc = [NSString stringWithFormat:@"%@|%@",_accountTf.text,_pwdTf.text];
        [arr addObject:strAcc];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kAccountRemArr"];
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"kAccountRemArr"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)registerAction:(id)sender {
//    RegisterVC * registerVC = [[RegisterVC alloc] initWithNibName:@"RegisterVC" bundle:[NSBundle mainBundle]];
//    [self.navigationController pushViewController:registerVC animated:YES];
    MemberNoticeVC * memberVC = [[MemberNoticeVC alloc] initWithNibName:@"MemberNoticeVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:memberVC animated:YES];
}
- (IBAction)switchAction:(id)sender {
    [_pwdTf setSecureTextEntry:_switchPwd.on];
}

- (IBAction)fogotPwdAction:(id)sender {
}
- (IBAction)remAction:(id)sender {
//    _remTbHeightCons.constant = (_remTbHeightCons.constant == 0 ? (dataSourceRemeber.count * 30.0): 0);
//    NSLog(@"remHei:%f",_remTbHeightCons.constant);
    [dataSourceRemeber removeAllObjects];
    [dataSourceRemeber addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"kAccountRemArr"]];
    [_remeberTb reloadData];
    if (_remTbHeightCons.constant == 0.0) {
        _remTbHeightCons.constant = dataSourceRemeber.count * 30.0;
    }else{
        _remTbHeightCons.constant = 0.0;
    }
    [_accountTf becomeFirstResponder];
}
@end
