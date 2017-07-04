//
//  ComDetailViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/7.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ComDetailViewController.h"
#import "UIWaitView.h"
#import "RvcNetWork.h"
#import "Config.h"
#import "UICode.h"
#import "RvcData.h"
#import "RvcHeader.h"
#import "ShopCartViewController.h"
#import "CommodityClass.h"

@interface ComDetailViewController ()<NetSocketDelegate>{
    NSMutableArray * _arrOrder;
}

@property (weak, nonatomic) IBOutlet UILabel *comLb;
@property (weak, nonatomic) IBOutlet UILabel *desComLb;
@property (weak, nonatomic) IBOutlet UILabel *amountLb;
- (IBAction)addAction:(id)sender;
- (IBAction)subtractAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numTf;

- (IBAction)buyAction:(id)sender;
@end

@implementation ComDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _arrOrder = [NSMutableArray array];
    
    _numTf.text = @"1";
    _comLb.text = _comInfo.serviceName;
    _desComLb.text = _comInfo.desc;
    _amountLb.text = [NSString stringWithFormat:@"%.2f",_comInfo.price];
}

- (IBAction)addAction:(id)sender {
    NSString * numTfStr = _numTf.text;
    _numTf.text = [NSString stringWithFormat:@"%zd",[numTfStr integerValue] + 1];
}

- (IBAction)subtractAction:(id)sender {
    NSString * numTfStr = _numTf.text;
    if ([numTfStr integerValue] == 1) {
        [[UIWaitView sharedClient] showPopUpView:@"购买数量不能小于1" withImage:@"alert" complement:^{
            
        }];
        return;
    }
    _numTf.text = [NSString stringWithFormat:@"%zd",[numTfStr integerValue] - 1];
}

- (IBAction)buyAction:(id)sender {
    CommodityClass * comm = [[CommodityClass alloc] init];
    
//    OrderInfo * order = [[OrderInfo alloc] init];
    comm.loginID = [UIData sharedClient].loginID;
    comm.serveId = _comInfo.serviceId;
    comm.price = _comInfo.price;
    comm.discount = 1;
    comm.quantity = [_numTf.text intValue];
    comm.amount = _comInfo.price * 1 * [_numTf.text intValue];
    
    _arrOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"orderArr"];
    
    NSData *archiveCarPriceData = [NSKeyedArchiver archivedDataWithRootObject:comm];
//    [[NSUserDefaults standardUserDefaults] setObject:archiveCarPriceData forKey:@"commObject"];
//    NSData *myEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"DataArray"];
//    self.dataList = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    
    [[RvcData shared] appendCacheWithMethod:Req_UserServeOrder useBlock:^(id cache, NSError *error)
     {
         if ([cache isKindOfClass:[NSMutableArray class]])
         {
             NSMutableArray *data = (NSMutableArray *)cache;
             if (_arrOrder.count > 0) {
                 [data arrayByAddingObjectsFromArray:_arrOrder];
                 [data addObject:archiveCarPriceData];
             }else{
                 [data addObject:archiveCarPriceData];
             }
         }
     }];
    [[NSUserDefaults standardUserDefaults] setObject:[[RvcData shared] dataObjWithMethod:Req_UserServeOrder] forKey:@"orderArr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    ShopCartViewController * shopVC = [[ShopCartViewController alloc] initWithNibName:@"ShopCartViewController" bundle:[NSBundle mainBundle]];
//    [self.navigationController pushViewController:shopVC animated:YES];
//    [RvcNetWork shared].response = self;
//    [[RvcNetWork shared] orderLoginId:[UIData sharedClient].loginID withServeId:_comInfo.serviceId withPrice:_comInfo.price withDiscount:1 withQuantity:[_numTf.text intValue] withAmount:_comInfo.price * 1 * [_numTf.text intValue] withSessionSid:[[RvcNetWork shared] nextSessionID]];
     
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"解析服务列表查询结果");
        [self parseOrder:data];
    });
}

- (void)parseOrder:(TcpResponse*)response{
    if (kUserOrderResponse != response.tag)
    {
        return;
    }
//    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] hideLoading];
            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        });
        return;
    }
//    [[UIWaitView sharedClient] showPrompt:@"下单成功" withImage:@"success"];
    [[UIWaitView sharedClient] showPopUpView:@"下单成功" withImage:@"success" complement:^{
        
    }];
}

@end
