//
//  OrderViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/6.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "OrderViewController.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "Config.h"
#import "UIWaitView.h"
#import "OrderTableViewCell.h"
#import "NoDataView.h"
#import "PendingPaymentVC.h"

@interface OrderViewController ()<NetSocketDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * _dataOrderArr;//用来存订单查询回来的所有结果
    NSMutableArray * _tableDataSource;//用来存当前tableview需要显示的数据
    NoDataView * _nodataView;
}
- (IBAction)allOrderAction:(id)sender;
- (IBAction)pendingPayment:(id)sender;
- (IBAction)alreadyOrder:(id)sender;
- (IBAction)alreadyComplementAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bottomLineLb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingBottomLine;
@property (weak, nonatomic) IBOutlet UIButton *allOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *pendingPayBtn;
@property (weak, nonatomic) IBOutlet UIButton *complementBtn;
@property (weak, nonatomic) IBOutlet UIButton *alreadyOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableViewOrder;
@property (weak, nonatomic) IBOutlet UIView *NoDataView;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataOrderArr = [NSMutableArray array];
    _tableDataSource = [NSMutableArray array];
    
    _tableViewOrder.delegate = self;
    _tableViewOrder.dataSource = self;
    
    _nodataView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NoDataView class]) owner:self options:nil].lastObject;
    _nodataView.dele = self;
    _nodataView.tipLb.text = @"暂无订单数据";
    _nodataView.frame = CGRectMake(0, 0, _NoDataView.frame.size.width, _NoDataView.frame.size.height);
    [_NoDataView addSubview:_nodataView];
    [self setHideNoDataView];
}

- (void)notificationBackResponse{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setHideNoDataView{
    if (_tableDataSource.count == 0) {
        _NoDataView.hidden = NO;
        _tableViewOrder.hidden = YES;
    }else if (_tableDataSource.count > 0){
        _NoDataView.hidden = YES;
        _tableViewOrder.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] userServeOrderListQueryLoginId:[UIData sharedClient].loginID withStatus:-1 withSessionID:[[RvcNetWork shared] nextSessionID]];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseUserOrderList:data];
    });
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
    for (UserOrderListInfo * info in _dataOrderArr) {
        [_tableDataSource addObject:info];
    }
    [self setHideNoDataView];
    [_tableViewOrder reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 206.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * _cellIdentifier = @"orderIdentifier";
    [tableView registerNib:[UINib nibWithNibName:@"OrderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_cellIdentifier];
    OrderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    UserOrderListInfo * info = [_tableDataSource objectAtIndex:indexPath.row];
    cell.timeLb.text = info.createDate;
    cell.orderNoLb.text = info.orderNum;
    cell.commodityLb.text = info.serviceName;
    cell.priceLb.text = [NSString stringWithFormat:@"%.2f",info.price];
    cell.numLb.text = [NSString stringWithFormat:@"%d",info.quantity];
    cell.totalPriceLb.text = [NSString stringWithFormat:@"%.2f",info.amount];
    switch (info.status) {
        case 0:
            cell.statusLb.text = @"待付款";
            break;
        case 1:
            cell.statusLb.text = @"待送件";
            break;
        case 2:
            cell.statusLb.text = @"已委托";
            break;
        case 3:
            cell.statusLb.text = @"服务中";
            break;
        case 6:
            cell.statusLb.text = @"待取件";
        case 9:
            cell.statusLb.text = @"订单完成";
            break;
        default:
            cell.statusLb.text = @"未知状态";
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserOrderListInfo * info = [_tableDataSource objectAtIndex:indexPath.row];
    NSLog(@"createDate:%@",info.createDate);
    switch (info.status) {
        case 0:
//            cell.statusLb.text = @"待付款";
        {
            PendingPaymentVC * pendPayVc = [[PendingPaymentVC alloc] initWithNibName:@"PendingPaymentVC" bundle:[NSBundle mainBundle]];
            pendPayVc.infoOrder = info;
            [self.navigationController pushViewController:pendPayVc animated:YES];
        }
            break;
        case 1:
//            cell.statusLb.text = @"待送件";
            break;
        case 2:
//            cell.statusLb.text = @"已委托";
            break;
        case 3:
//            cell.statusLb.text = @"服务中";
            break;
        case 6:
//            cell.statusLb.text = @"待取件";
        case 9:
//            cell.statusLb.text = @"订单完成";
            break;
        default:
//            cell.statusLb.text = @"未知状态";
            break;
    }
}

- (void)UINodataView{
    
}

- (IBAction)allOrderAction:(id)sender {
    _leadingBottomLine.constant = _allOrderBtn.frame.origin.x;
    [_tableDataSource removeAllObjects];
    for (UserOrderListInfo * info in _dataOrderArr) {
        [_tableDataSource addObject:info];
    }
    [self setHideNoDataView];
    [_tableViewOrder reloadData];
    _nodataView.tipLb.text = @"暂无订单数据";
}

- (IBAction)pendingPayment:(id)sender {
    _leadingBottomLine.constant = _pendingPayBtn.frame.origin.x;
    [_tableDataSource removeAllObjects];
    for (UserOrderListInfo * info in _dataOrderArr) {
        if (info.status == 0) {
            [_tableDataSource addObject:info];
        }
    }
    [self setHideNoDataView];
    [_tableViewOrder reloadData];
    _nodataView.tipLb.text = @"暂无待付款订单数据";
}

- (IBAction)alreadyOrder:(id)sender {
    _leadingBottomLine.constant = _alreadyOrderBtn.frame.origin.x;
    [_tableDataSource removeAllObjects];
    for (UserOrderListInfo * info in _dataOrderArr) {
        if (info.status == 2 || info.status == 1) {
            [_tableDataSource addObject:info];
        }
    }
    [self setHideNoDataView];
    [_tableViewOrder reloadData];
    _nodataView.tipLb.text = @"暂无下单订单数据";
}

- (IBAction)alreadyComplementAction:(id)sender {
    _leadingBottomLine.constant = _complementBtn.frame.origin.x;
    [_tableDataSource removeAllObjects];
    for (UserOrderListInfo * info in _dataOrderArr) {
        if (info.status == 9) {
            [_tableDataSource addObject:info];
        }
    }
    [self setHideNoDataView];
    [_tableViewOrder reloadData];
    _nodataView.tipLb.text = @"暂无已完成订单数据";
}

- (IBAction)cancelAction:(id)sender {
    _leadingBottomLine.constant = _cancelBtn.frame.origin.x;
     [_tableDataSource removeAllObjects];
    for (UserOrderListInfo * info in _dataOrderArr) {
        if (info.status == 5) {
            [_tableDataSource addObject:info];
        }
    }
    [self setHideNoDataView];
    [_tableViewOrder reloadData];
    _nodataView.tipLb.text = @"暂无取消订单数据";
}

@end
