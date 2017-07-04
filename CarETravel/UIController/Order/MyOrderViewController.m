//
//  MyOrderViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/16.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "MyOrderViewController.h"
#import "HWScanViewController.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "UIWaitView.h"
#import "UIData.h"
#import "Config.h"
#import "NoDataView.h"
#import "PendingPaymentVC.h"
#import "MyOrderTableViewCell.h"

#import "SortOrderViewController.h"
#import "zySheetPickerView.h"
#import "ComOrderViewController.h"

@interface MyOrderViewController ()<UITableViewDelegate,UITableViewDataSource,NetSocketDelegate,NodataNotificationBack>{
    NSMutableArray * _dataOrderArr;//用来存订单查询回来的所有结果
    NSMutableArray * _tableDataSource;//用来存当前tableview需要显示的数据
    NoDataView * _nodataView;
    UILabel * lb;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewMyOrder;
@property (weak, nonatomic) IBOutlet UIView *NoDataView;

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
//    UIBarButtonItem * messageBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_message"] style:UIBarButtonItemStylePlain target:self action:@selector(messageAction)];
//    
//    UIBarButtonItem * scanBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(scanAction)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:messageBarItem, scanBarItem, nil];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    lb.text = @"我的订单";
    lb.textColor = [UIColor whiteColor];
    lb.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lb];
    
    UIButton * upWhiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upWhiteBtn.frame = CGRectMake(75, 0, 20, 30);
    [upWhiteBtn setImage:[UIImage imageNamed:@"icon_upwhite"] forState:0];
    [view addSubview:upWhiteBtn];
    [upWhiteBtn addTarget:self action:@selector(listOrderTypeAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = view;
    
    _dataOrderArr = [NSMutableArray array];
    _tableDataSource = [NSMutableArray array];
    _tableViewMyOrder.delegate = self;
    _tableViewMyOrder.dataSource = self;
    _tableViewMyOrder.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewMyOrder.bounces = NO;
    
    _nodataView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NoDataView class]) owner:self options:nil].lastObject;
    _nodataView.dele = self;
    _nodataView.tipLb.text = @"暂无订单数据";
    _nodataView.frame = CGRectMake(0, 0, _NoDataView.frame.size.width, _NoDataView.frame.size.height);
    [_NoDataView addSubview:_nodataView];
    [self setHideNoDataView];
}

#pragma mark NodataNotificationBack代理
- (void)notificationBackResponse{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setHideNoDataView{
    if (_tableDataSource.count == 0) {
        _NoDataView.hidden = NO;
        _tableViewMyOrder.hidden = YES;
    }else if (_tableDataSource.count > 0){
        _NoDataView.hidden = YES;
        _tableViewMyOrder.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] userServeOrderListQueryLoginId:[UIData sharedClient].loginID withStatus:-1 withSessionID:[[RvcNetWork shared] nextSessionID]];
}

#pragma mark NetSocketDelegate
- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseUserOrderList:data];
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

- (void)parseUserOrderList:(TcpResponse*)response{
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
    _dataOrderArr = data;
    if (_tableDataSource.count > 0) {
        [_tableDataSource removeAllObjects];
    }
    
    for (UserOrderListInfo * info in _dataOrderArr) {
        [_tableDataSource addObject:info];
    }
    [self setHideNoDataView];
    [_tableViewMyOrder reloadData];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 271.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * _cellIdentifier = @"myorderIdentifier";
    [tableView registerNib:[UINib nibWithNibName:@"MyOrderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_cellIdentifier];
    MyOrderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    UserOrderListInfo * info = [_tableDataSource objectAtIndex:indexPath.row];
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
    cell.bloCancel = ^(int64_t orderId){
        NSLog(@"%lld",orderId);
        [[RvcNetWork shared] cancelOrderWithLoginId:[UIData sharedClient].loginID withOrderId:info.orderId withSessionSid:[[RvcNetWork shared] nextSessionID]];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/*
 //查询使用的状态
 enum
 {
 QUERY_ORDER_STATUS_ALL      = -1,        //所有
 QUERY_ORDER_STATUS_UNPAY    =  1,        //未支付
 QUERY_ORDER_STATUS_PLACED   =  2,        //已下单
 QUERY_ORDER_STATUS_FINISHED =  3,        //已完成
 QUERY_ORDER_STATUS_CANCELED =  4         //已取消
 };
 
 //订单状态
 enum
 {
 ORDER_STATUS_UN_PAY      = 0,          //未支付
 ORDER_STATUS_PAYED       = 1,          //已支付
 ORDER_STATUS_ENTRUSTED   = 2,          //已委托(已放钥匙至储物柜)
 ORDER_STATUS_IN_SERV     = 3,          //服务中(此状态及其后不允许退单审请)
 ORDER_STATUS_SERV_FINISH = 6,          //服务完成(将钥匙放至储物柜)
 ORDER_STATUS_FINISH      = 9,          //完成(钥匙交接车主)
 ORDER_STATUS_CANCELING   = 4,          //退单中
 ORDER_STATUS_STOP_SERV   = 7           //终止服务
 
 };
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserOrderListInfo * info = [_tableDataSource objectAtIndex:indexPath.row];
    switch (info.status) {
        case 0:
        {
            //代付款
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
            //            cell.statusLb.text = @"待取件";
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

- (void)listOrderTypeAction{
    NSLog(@"listOrderType");
    NSArray * data = [NSArray arrayWithObjects:@"待付款",@"待送件",@"已委托",@"已取消",@"服务中",@"待取件",@"订单完成", nil];
    zySheetPickerView * sheetPicker = [zySheetPickerView ZYSheetStringPickerWithTitle:data andHeadTitle:@"订单状态类型" Andcall:^(zySheetPickerView *pickerView, NSString *choiceString) {
        lb.text = choiceString;
        [_tableDataSource removeAllObjects];
        if ([choiceString isEqualToString:@"待付款"]) {
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 0) {
                    [_tableDataSource addObject:info];
                }
            }
            if (_tableDataSource.count == 0) {
                [[UIWaitView sharedClient] showPopUpView:@"暂无待付款订单记录" withImage:@"alert" complement:^{
                    
                }];
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
        if ([choiceString isEqualToString:@"待送件"]) {
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 1) {
                    [_tableDataSource addObject:info];
                }
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
        if ([choiceString isEqualToString:@"已委托"]) {
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 2) {
                    [_tableDataSource addObject:info];
                }
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
        if ([choiceString isEqualToString:@"服务中"]) {
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 3) {
                    [_tableDataSource addObject:info];
                }
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
        if ([choiceString isEqualToString:@"已取消"]) {
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 4) {
                    [_tableDataSource addObject:info];
                }
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
        if ([choiceString isEqualToString:@"待取件"]) {
        
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 6) {
                    [_tableDataSource addObject:info];
                }
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
        if ([choiceString isEqualToString:@"订单完成"]) {
            for (UserOrderListInfo * info in _dataOrderArr) {
                if (info.status == 9) {
                    [_tableDataSource addObject:info];
                }
            }
            [self setHideNoDataView];
            [_tableViewMyOrder reloadData];
        }
    }];
    [sheetPicker show];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)messageAction{
    
}

- (void)scanAction{
    HWScanViewController * hwScanVC = [[HWScanViewController alloc] init];
    [self.navigationController pushViewController:hwScanVC animated:YES];
}

@end
