//
//  ShopCartViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/8.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ShopCartViewController.h"
#import "ShopTableViewCell.h"
#import "RvcData.h"
#import "RvcHeader.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "Config.h"
#import "UIWaitView.h"
#import "CommodityClass.h"

@interface ShopCartViewController ()<UITableViewDelegate,UITableViewDataSource,NetSocketDelegate>{
    NSMutableArray * _dataSourceShop;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewShop;

@end

@implementation ShopCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableViewShop.dataSource = self;
    _tableViewShop.delegate = self;
    _dataSourceShop = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    NSArray * arrShop = [[NSUserDefaults standardUserDefaults] objectForKey:@"orderArr"];
    for (NSData * data in arrShop) {
        CommodityClass * comClass = [NSKeyedUnarchiver unarchiveObjectWithData: data];
        [_dataSourceShop addObject:comClass];
    }
    [_tableViewShop reloadData];
//    [RvcNetWork shared].response = self;
//    [[RvcNetWork shared] userServeOrderListQueryLoginId:[UIData sharedClient].loginID withStatus:0 withSessionID:[[RvcNetWork shared] nextSessionID]];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseShopUserOrderList:data];
    });
}

- (void)parseShopUserOrderList:(TcpResponse*)response{
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
//    _dataSourceShop = data;
    for (UserOrderListInfo * info in data) {
        [_dataSourceShop addObject:info];
    }
    [_tableViewShop reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSourceShop.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 215.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * _cellIdentifier = @"shopIdentifier";
    [tableView registerNib:[UINib nibWithNibName:@"ShopTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_cellIdentifier];
    ShopTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
