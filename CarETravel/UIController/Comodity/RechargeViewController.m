//
//  RechargeViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/18.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "RechargeViewController.h"
#import "ItemRechargeView.h"
#import "RvcNetWork.h"
#import "UICode.h"
#import "UIWaitView.h"
#import "Config.h"
#import <AlipaySDK/AlipaySDK.h>

@interface RechargeViewController ()<NetSocketDelegate>{
    NSMutableArray * arrItemTitle;
    NSMutableArray * optionArr;
    NSInteger currentSelIndex;
}
@property (weak, nonatomic) IBOutlet UIButton *recordIconBtn;
@property (weak, nonatomic) IBOutlet UIButton *explanIconBtn;
- (IBAction)explanationAciton:(id)sender;
- (IBAction)recordAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *itemSelectView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemSelectHeightCons;
@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;
- (IBAction)rechargeAction:(id)sender;
- (IBAction)protoRechageAction:(id)sender;

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backRechargeAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    _rechargeBtn.layer.cornerRadius = 2.0;
    _rechargeBtn.clipsToBounds = YES;
    
    optionArr = [[NSMutableArray alloc] init];
    arrItemTitle = [NSMutableArray arrayWithObjects:@"10,10",@"20,19.9",@"50,49",@"100,99",@"200,198",@"300,297", nil];
}

//- (void)viewWillLayoutSubviews{
//    [self itemBoarderSet];
//}

- (void)viewDidLayoutSubviews{
    [self itemBoarderSet];
}

- (void)backRechargeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)itemBoarderSet{
    float width = 80.0;
    float height = 60.0;
    float ySep = 20.0;
    float xSep = (kUIScreenWidth - 3 * width) / 4;
    
    for (int i = 0; i < 6; i ++) {
        ItemRechargeView * item1 = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ItemRechargeView class]) owner:self options:nil].lastObject;
        item1.indexOption = 510 + i;
        if (i == 0) {
            item1.selectIf = YES;
            item1.backgroundColor = [UIColor colorWithRed:1.0 green:154.0/255 blue:24.0/255 alpha:1.0];
            item1.orginPriceLb.textColor = [UIColor whiteColor];
            item1.realPriceLb.textColor = [UIColor whiteColor];
            currentSelIndex = item1.indexOption;
        }else
            item1.selectIf = NO;
        NSString * titleStr = [arrItemTitle objectAtIndex:i];
        NSString * preStr = [titleStr componentsSeparatedByString:@","].firstObject;
        NSString * behindStr = [titleStr componentsSeparatedByString:@","].lastObject;
        item1.orginPriceLb.text = preStr;
        item1.realPriceLb.text = [NSString stringWithFormat:@"售价%@元",behindStr];
        item1.frame = CGRectMake((xSep + width) * (i%3) + xSep, (i / 3) * (ySep +  height) + ySep, width, height);
        item1.layer.borderColor = [UIColor colorWithRed:252.0/255 green:154.0/255 blue:20.0/255 alpha:1.0].CGColor;
        item1.layer.borderWidth = 1.0;
        
        __weak RechargeViewController * weakSelf = self;
        item1.bloOption = ^(NSInteger index){
            [weakSelf changeOptionItemStateWithIndex:index];
        };
        [optionArr addObject:item1];
        [_itemSelectView addSubview:item1];
    }
}

- (void)changeOptionItemStateWithIndex:(NSInteger)indexSel{
    currentSelIndex = indexSel;
    for (ItemRechargeView *rechargeView in optionArr) {
        if (rechargeView.indexOption == indexSel) {
            rechargeView.selectIf = YES;
            rechargeView.backgroundColor = [UIColor colorWithRed:1.0 green:154.0/255 blue:24.0/255 alpha:1.0];
            rechargeView.orginPriceLb.textColor = [UIColor whiteColor];
            rechargeView.realPriceLb.textColor = [UIColor whiteColor];
        }else{
            rechargeView.selectIf = NO;
            rechargeView.backgroundColor = [UIColor whiteColor];
            rechargeView.orginPriceLb.textColor = [UIColor colorWithRed:1.0 green:154.0/255 blue:24.0/255 alpha:1.0];
            rechargeView.realPriceLb.textColor = [UIColor colorWithRed:1.0 green:154.0/255 blue:24.0/255 alpha:1.0];
        }
    }
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"解析服务列表查询结果");
        [self parseChargeResponse:data];
    });
}

- (void)parseChargeResponse:(TcpResponse*)response{
    if (kUserChargeResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
//    if ([data isKindOfClass:[NSString class]]) {
//        return;
//    }
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] hideLoading];
            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        });
        return;
    }
    //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
    NSString *appScheme = @"com.sunrise.CarETravel";
    // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = data;
    
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@,%@",resultDic,[resultDic objectForKey:@"memo"]);
        
    }];
    
//    NSLog(@"chargeReturnStr:%@",data);
//    [[UIWaitView sharedClient] showPopUpView:@"充值成功" withImage:@"success" complement:^{
//    }];
}


- (IBAction)explanationAciton:(id)sender {
}

- (IBAction)recordAction:(id)sender {
}
- (IBAction)rechargeAction:(id)sender {
    Float64 amount = 0.1;
    switch (currentSelIndex) {
        case 510:
            amount = 10.0;
            break;
        case 511:
            amount = 20.0;
            break;
        case 512:
            amount = 50.0;
            break;
        case 513:
            amount = 100.0;
            break;
        case 514:
            amount = 200.0;
            break;
        case 515:
            amount = 300.0;
            break;
        default:
            amount = 10.0;
            break;
    }
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] chargeWithLoginId:[UIData sharedClient].loginID withAmount:amount withSessionSid:[[RvcNetWork shared] nextSessionID]];
//    NSLog(@"currentIndex:%ld",(long)currentSelIndex);
    
}

- (IBAction)protoRechageAction:(id)sender {
}

@end
