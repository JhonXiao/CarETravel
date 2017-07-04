//
//  CustomServiceVC.m
//  CarETravel
//
//  Created by yg on 2017/4/26.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "CustomServiceVC.h"
#import "RvcNetWork.h"
#import "Config.h"
#import "UICode.h"
#import "UIWaitView.h"

@interface CustomServiceVC ()<NetSocketDelegate>

@property (weak, nonatomic) IBOutlet UIView *csView;
@property (weak, nonatomic) IBOutlet UILabel *contentCsLb;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
- (IBAction)okBtnAction:(id)sender;

@end

@implementation CustomServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"客服信息";
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backMeFromCusAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
}

- (void)viewWillAppear:(BOOL)animated{
    _csView.layer.cornerRadius = 3.0;
    _csView.clipsToBounds = YES;
    _okBtn.layer.cornerRadius = 3.0;
    _okBtn.clipsToBounds = YES;
    
//    CSInfo * infoCusSer = [[UIData sharedClient] dataObjWithKey:@"kCustomerServiceInfoData"];
//    if (infoCusSer) {
//        _contentCsLb.text = infoCusSer.csInfo;
//    }else{
//        
//    }
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] customerServiceQueryWithLoginID:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
}

- (void)backMeFromCusAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    CSInfo * infoS = data;
    [[UIData sharedClient] append:infoS withKey:@"kCustomerServiceInfoData"];
    _contentCsLb.text = infoS.csInfo;
}

- (IBAction)okBtnAction:(id)sender {
//    self.tabbarBlo(0);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
