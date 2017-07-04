//
//  DataViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/20.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "DataViewController.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "Config.h"
#import "UIWaitView.h"
#import "InformModifyViewController.h"

@interface DataViewController ()<NetSocketDelegate>
@property (weak, nonatomic) IBOutlet UIButton *txBtn;
@property (weak, nonatomic) IBOutlet UILabel *carNoLb;
- (IBAction)selectCarNoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *yeLb;
@property (weak, nonatomic) IBOutlet UILabel *sexLb;
@property (weak, nonatomic) IBOutlet UILabel *parkSlotLb;
@property (weak, nonatomic) IBOutlet UILabel *bandLb;
@property (weak, nonatomic) IBOutlet UILabel *cartypeL;
@property (weak, nonatomic) IBOutlet UILabel *colorLb;

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"个人资料";
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backMeAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    UIBarButtonItem * modifyDataItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modifyData)];
    self.navigationItem.rightBarButtonItem = modifyDataItem;
//    UIBarButtonItem * messageBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_message"] style:UIBarButtonItemStylePlain target:self action:@selector(messageDataAction)];
//
//    UIBarButtonItem * scanBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(scanDataAction)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:messageBarItem, scanBarItem, nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] getUserBalanceWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    if ([[UIData sharedClient] dataObjWithKey:@"kUserInfoData"]) {
        RefineUserInfo * getRefineInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
        _carNoLb.text = getRefineInfo.carNo;
        _parkSlotLb.text = getRefineInfo.parkSlot;
        switch (getRefineInfo.sex) {
            case 0:
                _sexLb.text = @"先生/女士";
                break;
            case 1:
                _sexLb.text = @"先生";
                break;
            case 2:
                _sexLb.text = @"女士";
                break;
                
            default:
                break;
        }
    }else{
        
        [[RvcNetWork shared] queryUserDataWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    }
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseDataUserBalanceList:data];
    });
}

- (void)parseDataUserBalanceList:(TcpResponse*)response{
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
    _yeLb.text = [NSString stringWithFormat:@"%.2f",[data doubleValue]];
}

- (void)messageDataAction{
    
}

- (void)scanDataAction{
    
}

- (void)modifyData{
    InformModifyViewController * infoMod = [[InformModifyViewController alloc] initWithNibName:@"InformModifyViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:infoMod animated:YES];
}

- (void)backMeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectCarNoAction:(id)sender {
    NSLog(@"选择车牌号（功能建设中）");
}
@end
