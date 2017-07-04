//
//  PendingPaymentVC.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/13.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "PendingPaymentVC.h"
#import "MyOrderTableViewCell.h"
#import "UIData.h"
#import "RvcNetWork.h"
#import "Config.h"
#import "UICode.h"
#import "UIWaitView.h"

@interface PendingPaymentVC ()<UITableViewDelegate,UITableViewDataSource,NetSocketDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
- (IBAction)payAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPay;

@end

@implementation PendingPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"付款";
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    _tableViewPay.delegate = self;
    _tableViewPay.dataSource = self;
    _tableViewPay.showsVerticalScrollIndicator = NO;
    _tableViewPay.bounces = NO;
    _tableViewPay.backgroundColor = [UIColor greenColor];
    _tableViewPay.sectionFooterHeight = 0.0;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 247.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * _cellIdentifier = @"paymentOrderIdentifier";
    [tableView registerNib:[UINib nibWithNibName:@"MyOrderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_cellIdentifier];
    MyOrderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    UserOrderListInfo * info = _infoOrder;
    cell.orderOpenTimeLb.text = info.createDate;
    cell.orderNoLb.text = info.orderNum;
    cell.serviceItemLb.text = info.serviceName;
    cell.allPriceLb.text = [NSString stringWithFormat:@"%.2f",info.amount];
    cell.estimatedFinshTimeLb.text = info.createDate;
    RefineUserInfo * getReUserInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
    cell.carModelLb.text = getReUserInfo.carNo;
    cell.gridIdLb.text = [NSString stringWithFormat:@"%d",info.gridId];
    cell.gridInfoLb.text = info.gridInfo;
    [cell.orderStatusBtn setTitle:@"待付款" forState:0];
    [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:252.0/255 green:17.0/255 blue:17.0/255 alpha:1.0]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (IBAction)payAction:(id)sender {
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] orderPaymentWithLoginId:[UIData sharedClient].loginID withOrderId:_infoOrder.orderId withAmount:_infoOrder.amount withSessionSid:[[RvcNetWork shared] nextSessionID]];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseOrderPaymentResponse:data];
    });
}

- (void)parseOrderPaymentResponse:(TcpResponse *)response{
    if (kOrderPaymentResponse != response.tag)
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

    [[UIWaitView sharedClient] showPopUpView:@"支付成功" withImage:@"success" complement:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
