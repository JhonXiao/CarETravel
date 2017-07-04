//
//  HomeViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/4.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "HomeViewController.h"
#import "FLTabBarController.h"
#import "ClearCarViewController.h"
#import "MallViewController.h"
#import "RvcNetWork.h"
#import "UIWaitView.h"
#import "UICode.h"
#import "Config.h"
#import "ShopCartViewController.h"
#import "HomeTableViewCell.h"
#import "ComOrderViewController.h"
#import "ComDetailViewController.h"

@interface HomeViewController ()<NetSocketDelegate,UITableViewDataSource,UITableViewDelegate>{
    ServiceListInfo * _serviceInfo;
    NSMutableArray * _serviceArr;
    ServiceListInfo * comInfo;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewHome;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"车E行";
    
    _tableViewHome.delegate = self;
    _tableViewHome.dataSource = self;
    _tableViewHome.bounces = NO;
    _tableViewHome.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewHome.showsVerticalScrollIndicator = NO;
    _serviceArr = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] serviceListQueryLoginId:[UIData sharedClient].loginID withSessionID:[[RvcNetWork shared] nextSessionID]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _serviceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * _cellIdentifier = @"homeIdentifier";
    [tableView registerNib:[UINib nibWithNibName:@"HomeTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_cellIdentifier];
    HomeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    _serviceInfo = [_serviceArr objectAtIndex:indexPath.row];
    cell.comInfo = [_serviceArr objectAtIndex:indexPath.row];
    cell.block = ^(ServiceListInfo * info){
//        [[RvcNetWork shared] orderLoginId:[UIData sharedClient].loginID withServeId:info.serviceId withPrice:info.price withDiscount:1.0 withQuantity:1 withAmount:info.price withSessionSid:[[RvcNetWork shared] nextSessionID]];
//        comInfo = info;
        ComOrderViewController * comOrderVC = [[ComOrderViewController alloc] initWithNibName:@"ComOrderViewController" bundle:[NSBundle mainBundle]];
        comOrderVC.comInfo = info;
        [self.navigationController pushViewController:comOrderVC animated:YES];
    };
    cell.styleLB.text = _serviceInfo.serviceName;
    cell.titleLb.text = _serviceInfo.serviceName;
    cell.descLb.text = _serviceInfo.desc;
    cell.priceLb.text = [NSString stringWithFormat:@"￥%.2f",_serviceInfo.price];
    [cell.headerImageBtn setImage:[UIImage imageNamed:@"icon_washcar"] forState:0];
    if ([_serviceInfo.serviceName isEqualToString:@"20元洗车"]) {
        [cell.headerImageBtn setImage:[UIImage imageNamed:@"icon_washcar"] forState:0];
    }else if ([_serviceInfo.serviceName isEqualToString:@"内饰清洁"]){
        [cell.headerImageBtn setImage:[UIImage imageNamed:@"icon_washair"] forState:0];
    }else if ([_serviceInfo.serviceName isEqualToString:@"换机油"]){
        [cell.headerImageBtn setImage:[UIImage imageNamed:@"icon_wax"] forState:0];
    }else if ([_serviceInfo.serviceName isEqualToString:@"全车打蜡"]){
        [cell.headerImageBtn setImage:[UIImage imageNamed:@"icon_wax"] forState:0];
    }
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    comInfo = [_serviceArr objectAtIndex:indexPath.row];
//    [[RvcNetWork shared] orderLoginId:[UIData sharedClient].loginID withServeId:comInfo.serviceId withPrice:comInfo.price withDiscount:1.0 withQuantity:1 withAmount:comInfo.price withSessionSid:[[RvcNetWork shared] nextSessionID]];
//}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseServiceList:data];
//        [self parseOrder:data];
    });
}

- (void)parseOrder:(TcpResponse*)response{
    if (kUserOrderResponse != response.tag)
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
    
    UserOrderInfo * orderInfo = data;
    [[UIWaitView sharedClient] showPopUpView:@"下单成功,请完成支付" withImage:@"success" complement:^{
        ComOrderViewController * comOrderVC = [[ComOrderViewController alloc] initWithNibName:@"ComOrderViewController" bundle:[NSBundle mainBundle]];
        comOrderVC.comInfo = comInfo;
        comOrderVC.orderInfo = orderInfo;
        [self.navigationController pushViewController:comOrderVC animated:YES];
    }];
}

- (void)parseServiceList:(TcpResponse*)response{
    if (kServiceResponse != response.tag)
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
    _serviceArr = data;
//    _serviceInfo = [data objectAtIndex:0];
//    NSLog(@"serveName:%@",_serviceInfo.serviceName);
    [_tableViewHome reloadData];
}

@end
