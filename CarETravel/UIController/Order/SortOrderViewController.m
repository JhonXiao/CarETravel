//
//  SortOrderViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/29.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "SortOrderViewController.h"
#import "MyOrderTableViewCell.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "Config.h"
#import "UIWaitView.h"
#import "PendingPaymentVC.h"
#import "HWScanViewController.h"
#import "NoDataView.h"
#import "ComOrderViewController.h"

@interface SortOrderViewController ()<UITableViewDelegate,UITableViewDataSource,NetSocketDelegate,NodataNotificationBack>{
    NSMutableArray * _dataOrderSortArr;
    NoDataView * _nodataView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewSort;
@property (weak, nonatomic) IBOutlet UIView *NODataView;

@end

@implementation SortOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = _titleStr;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    _dataOrderSortArr = [NSMutableArray array];
//    _tableDataSource = [NSMutableArray array];
    _tableViewSort.delegate = self;
    _tableViewSort.dataSource = self;
    _tableViewSort.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewSort.bounces = NO;
    
    _nodataView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NoDataView class]) owner:self options:nil].lastObject;
    _nodataView.dele = self;
    _nodataView.tipLb.text = @"暂无订单数据";
    _nodataView.frame = CGRectMake(0, 0, _NODataView.frame.size.width, _NODataView.frame.size.height);
    [_NODataView addSubview:_nodataView];
    [self setHideNoDataView];
}

#pragma mark NodataNotificationBack代理
- (void)notificationBackResponse{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setHideNoDataView{
    if (_dataOrderSortArr.count == 0) {
        _NODataView.hidden = NO;
        _tableViewSort.hidden = YES;
    }else if (_dataOrderSortArr.count > 0){
        _NODataView.hidden = YES;
        _tableViewSort.hidden = NO;
    }
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] userServeOrderListQueryLoginId:[UIData sharedClient].loginID withStatus:-1 withSessionID:[[RvcNetWork shared] nextSessionID]];
}

#pragma mark NetSocketDelegate
- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseSortUserOrderList:data];
        [self parseCancelOrder:data];
    });
}

- (void)parseCancelOrder:(TcpResponse *)response{
    if (kCancelOrderResponse != response.tag) {
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
    CancelOrderInfo * cancelOrderInfo = data;
    [[RvcNetWork shared] userServeOrderListQueryLoginId:[UIData sharedClient].loginID withStatus:-1 withSessionID:[[RvcNetWork shared] nextSessionID]];
}

- (void)parseSortUserOrderList:(TcpResponse*)response{
    if (kUserOrderListResponse != response.tag)
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
    NSArray * resArr = data;
    if (_dataOrderSortArr.count > 0) {
        [_dataOrderSortArr removeAllObjects];
    }
    
    for (UserOrderListInfo * info in resArr) {
        if ([_titleStr isEqualToString:@"待付款"]) {
            if (info.status == 0) {
                [_dataOrderSortArr addObject:info];
            }
        }
        if ([_titleStr isEqualToString:@"已下单"]) {
            if (info.status == 1 || info.status == 2 || info.status == 3 || info.status == 6) {
                [_dataOrderSortArr addObject:info];
            }
        }
        if ([_titleStr isEqualToString:@"已取消"]) {
            if (info.status == 4) {
                [_dataOrderSortArr addObject:info];
            }
        }
        if ([_titleStr isEqualToString:@"已完成"]) {
            if (info.status == 9) {
                [_dataOrderSortArr addObject:info];
            }
        }
    }
    [self setHideNoDataView];
    [_tableViewSort reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataOrderSortArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 271.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * _cellIdentifier = @"myorderSortIdentifier";
    [tableView registerNib:[UINib nibWithNibName:@"MyOrderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_cellIdentifier];
    MyOrderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    UserOrderListInfo * info = [_dataOrderSortArr objectAtIndex:indexPath.row];
    cell.orderOpenTimeLb.text = info.createDate;
    cell.orderNoLb.text = info.orderNum;
    cell.serviceItemLb.text = info.serviceName;
    cell.allPriceLb.text = [NSString stringWithFormat:@"%.2f",info.amount];
    cell.estimatedFinshTimeLb.text = info.createDate;
    cell.gridIdLb.text = [NSString stringWithFormat:@"%d",info.gridId];
    if (info.gridId == 0) {
        cell.gridIdLb.text = @"";
    }
    cell.gridInfoLb.text = info.gridInfo;
    
    RefineUserInfo * getReUserInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
    cell.carModelLb.text = getReUserInfo.carNo;
    switch (info.status) {
        case 0:{
            [cell.orderStatusBtn setTitle:@"待付款" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:252.0/255 green:17.0/255 blue:17.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:255.0/255 green:154.0/255 blue:20.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:YES];
            break;
        }
        case 1:{
            [cell.orderStatusBtn setTitle:@"待送件" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:252.0/255 green:17.0/255 blue:17.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:255.0/255 green:154.0/255 blue:20.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:YES];
            break;
        }
        case 2:{
            [cell.orderStatusBtn setTitle:@"已委托" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:3.0/255 green:191.0/255 blue:51.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:255.0/255 green:154.0/255 blue:20.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:YES];
            break;
        }
        case 3:{
            [cell.orderStatusBtn setTitle:@"服务中" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:3.0/255 green:191.0/255 blue:51.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:NO];
            break;
        }
        case 4:{
            [cell.orderStatusBtn setTitle:@"已取消" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:255.0/255 green:154.0/255 blue:20.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:NO];
            break;
        }
        case 6:{
            [cell.orderStatusBtn setTitle:@"待取件" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:3.0/255 green:191.0/255 blue:51.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:NO];
            break;
        }
        case 9:{
            [cell.orderStatusBtn setTitle:@"订单完成" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:255.0/255 green:154.0/255 blue:20.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setBackgroundColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]];
            [cell.cancelOrderBtn setEnabled:NO];
            break;
        }
        default:
        {
            [cell.orderStatusBtn setTitle:@"未知状态" forState:0];
            [cell.orderStatusBtn setBackgroundColor:[UIColor colorWithRed:3.0/255 green:191.0/255 blue:51.0/255 alpha:1.0]];
            break;
        }
    }
    cell.bloCancel = ^(int64_t orid){
//        NSLog(@"%@",orderIdStr);
        [[RvcNetWork shared] cancelOrderWithLoginId:[UIData sharedClient].loginID withOrderId:info.orderId withSessionSid:[[RvcNetWork shared] nextSessionID]];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserOrderListInfo * info = [_dataOrderSortArr objectAtIndex:indexPath.row];
    switch (info.status) {
        case 0:
        {
            //待付款
//            PendingPaymentVC * pendPayVc = [[PendingPaymentVC alloc] initWithNibName:@"PendingPaymentVC" bundle:[NSBundle mainBundle]];
//            pendPayVc.infoOrder = info;
//            [self.navigationController pushViewController:pendPayVc animated:YES];
            ComOrderViewController * comOrderVC = [[ComOrderViewController alloc] initWithNibName:@"ComOrderViewController" bundle:[NSBundle mainBundle]];
            UserOrderInfo * orderInfo = [[UserOrderInfo alloc] init];
            orderInfo.loginID = [UIData sharedClient].loginID;
            orderInfo.orderId = info.orderId;
            comOrderVC.orderInfo = orderInfo;
            
            ServiceListInfo * serviceInfo = [[ServiceListInfo alloc] init];
            serviceInfo.serviceId = info.serviceId;
            serviceInfo.serviceCode = info.serviceNum;
            serviceInfo.serviceName = info.serviceName;
            serviceInfo.desc = info.desc;
            serviceInfo.price = info.price;
            //            serviceInfo.iconIndex = info.iconIndx;
            comOrderVC.comInfo = serviceInfo;
            [self.navigationController pushViewController:comOrderVC animated:YES];
        }
            break;
        case 1:
        {
            //待送件
            HWScanViewController * hwScanVC = [[HWScanViewController alloc] init];
            hwScanVC.orderid = info.orderId;
            [self.navigationController pushViewController:hwScanVC animated:YES];
        }
            break;
        case 2:
            //            cell.statusLb.text = @"已委托";
            break;
        case 3:
            //            cell.statusLb.text = @"服务中";
            break;
        case 6:
            //            cell.statusLb.text = @"待取件";{
        {
            HWScanViewController * hwScanVC = [[HWScanViewController alloc] init];
            hwScanVC.orderid = info.orderId;
            [self.navigationController pushViewController:hwScanVC animated:YES];
        }
        case 9:
            //            cell.statusLb.text = @"订单完成";
            break;
        default:
            //            cell.statusLb.text = @"未知状态";
            break;
    }
}

@end
