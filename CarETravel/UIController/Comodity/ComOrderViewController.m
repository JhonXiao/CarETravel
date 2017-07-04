//
//  ComOrderViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/16.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ComOrderViewController.h"
#import "RechargeViewController.h"
#import "RvcNetWork.h"
#import "UIData.h"
#import "UIWaitView.h"
#import "UICode.h"
#import "Config.h"
#import "HWScanViewController.h"
#import "InformModifyViewController.h"

@interface ComOrderViewController ()<NetSocketDelegate,UITextFieldDelegate>{
    double yue;
    double amountOrder;
    int _sexSelIndex;//0-都未选中，1-选择先生，2-选择女士
    NSInteger _typeParking;//0-固定，1-临时
    
    UIToolbar *topView;
}
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
- (IBAction)contactCustomerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *carModelLb;
@property (weak, nonatomic) IBOutlet UILabel *typeItemLb;
@property (weak, nonatomic) IBOutlet UILabel *servicePriceLv;
@property (weak, nonatomic) IBOutlet UILabel *offerLb;
@property (weak, nonatomic) IBOutlet UILabel *balanceLb;
@property (weak, nonatomic) IBOutlet UIButton *paymentBtn;
- (IBAction)payAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stylePayHeightCons;
@property (weak, nonatomic) IBOutlet UIButton *alipaySelectBtn;
- (IBAction)alipaySelectAction:(id)sender;
- (IBAction)morePayWay:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *iconMorePayBtn;
@property (weak, nonatomic) IBOutlet UIView *stylePayView;

@property (weak, nonatomic) IBOutlet UILabel *cusNameLb;
@property (weak, nonatomic) IBOutlet UIButton *maleSelBtn;
- (IBAction)maleSelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;
- (IBAction)femaleAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *carNoTf;
@property (weak, nonatomic) IBOutlet UIButton *parkingFixBtn;
- (IBAction)parkingFixAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *parkingTemBtn;
- (IBAction)parkingTemAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *parkingTf;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ComOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"支付中心";
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backComOrderAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    _carNoTf.delegate = self;
    _parkingTf.delegate = self;
    
    [self hideKeboardAdd];
    [_carNoTf setInputAccessoryView:topView];
    [_parkingTf setInputAccessoryView:topView];
}

#pragma mark 隐藏键盘的方法
-(void)dismissKeyBoard
{
    [_carNoTf resignFirstResponder];
    [_parkingTf resignFirstResponder];
}

- (void)hideKeboardAdd{
    topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,30)];
    [topView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem *btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton= [[UIBarButtonItem alloc] initWithTitle:@"完成" style:
                                 UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonArray=[NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonArray];
}

- (void)viewWillAppear:(BOOL)animated{
    [self tfPlaceHolderSet];
    
    [RvcNetWork shared].response = self;
    NSLog(@"comInfoPrice:%f,%@",_comInfo.price,_comInfo);
    
    //余额查询
    [[RvcNetWork shared] getUserBalanceWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    _priceLb.text = [NSString stringWithFormat:@"￥%.f",_comInfo.price];
    _servicePriceLv.text = [NSString stringWithFormat:@"￥%.f",_comInfo.price];
    
    _carModelLb.text = _comInfo.serviceName;
    _typeItemLb.text = _comInfo.desc;
    
    RefineUserInfo * getReUserInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
    _cusNameLb.text = getReUserInfo.name;
    if (getReUserInfo.sex == 0) {
        [self.maleSelBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
        [self.femaleBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    }else if (getReUserInfo.sex == 1){
        [self.maleSelBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self.femaleBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    }else if (getReUserInfo.sex == 2){
        [self.maleSelBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
        [self.femaleBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
    }
    _sexSelIndex = getReUserInfo.sex;
    
    _carNoTf.text = getReUserInfo.carNo;
    if (getReUserInfo.parkType == 0) {
        [self.parkingFixBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self.parkingTemBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    }else if (getReUserInfo.parkType == 1){
        [self.parkingFixBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
        [self.parkingTemBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
    }
    _typeParking = getReUserInfo.parkType;
    _parkingTf.text = getReUserInfo.parkSlot;
    
}

#pragma mark TextField PlaceHolder设置
- (void)tfPlaceHolderSet{
    NSString * str = @"请输入车牌号码(格式:粤A00000)";
    // 创建 NSMutableAttributedString
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置字体和设置字体的范围
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:12.0f]
                    range:NSMakeRange(0, str.length)];
    _carNoTf.attributedPlaceholder = attrStr;
    
    str = @"格式:X区X层XXXX位";
    NSMutableAttributedString *attrStrPark = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置字体和设置字体的范围
    [attrStrPark addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12.0f]
                        range:NSMakeRange(0, str.length)];
//    attrStrPark addAttribute:NSParagraphStyleAttributeName value:<#(nonnull id)#> range:<#(NSRange)#>
    _parkingTf.attributedPlaceholder = attrStrPark;
}

#pragma mark 检查数据
- (BOOL)checkDataComple{
    if ([_cusNameLb.text isEqualToString:@"未知"]||[_cusNameLb.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPopUpView:@"请完善资料" withImage:@"alert" complement:^{
            InformModifyViewController * informVC = [[InformModifyViewController alloc] initWithNibName:@"InformModifyViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:informVC animated:YES];
        }];
        return NO;
    }
    if (_sexSelIndex == 0) {
        [[UIWaitView sharedClient] showPrompt:@"请选择称呼" withImage:@"alert"];
        return NO;
    }
    if ([_carNoTf.text isEqualToString:@""]||[_carNoTf.text isEqualToString:@"未知"]) {
        [[UIWaitView sharedClient] showPrompt:@"请输入车牌号" withImage:@"alert"];
        return NO;
    }
    if ([_parkingTf.text isEqualToString:@""]||[_parkingTf.text isEqualToString:@"未知"]) {
        [[UIWaitView sharedClient] showPrompt:@"请输入停车位" withImage:@"alert"];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkUserDataChange{
    RefineUserInfo * getReUserInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
    if (_sexSelIndex != getReUserInfo.sex) {
        return YES;
    }
    if (_typeParking != getReUserInfo.parkType) {
        return YES;
    }
    if (![_carNoTf.text isEqualToString:getReUserInfo.carNo]) {
        return YES;
    }
    if (![_parkingTf.text isEqualToString:getReUserInfo.parkSlot]) {
        return YES;
    }
    return NO;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _scrollView.contentOffset = CGPointMake(0, 250);
    if ([textField isEqual:_carNoTf]) {
        _carNoTf.text = @"";
    }
    if ([textField isEqual:_parkingTf]) {
        _parkingTf.text = @"";
    }
    return YES;
}

#pragma mark NetSocketDelegate
- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseComUserBalanceList:data];
        [self parseOrderPaymentResponse:data];
        [self parseComModifyUserInfoResponse:data];
        [self parseAfterModifyUserInfo:data];
        [self parseOrder:data];
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
    
    UserOrderInfo * orderRecevieInfo = data;
    _orderInfo = orderRecevieInfo;
//    [[UIWaitView sharedClient] showPopUpView:@"下单成功,请完成支付" withImage:@"success" complement:^{
//    }];
    if (yue < _comInfo.price) {
        [[UIWaitView sharedClient] showPopUpView:@"账户余额不足，请充值后再试" withImage:@"tips_confirm" complement:^{
            RechargeViewController * rechangeVC = [[RechargeViewController alloc] initWithNibName:@"RechargeViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:rechangeVC animated:YES];
        }];
    }else{
        [[RvcNetWork shared] orderPaymentWithLoginId:[UIData sharedClient].loginID withOrderId:_orderInfo.orderId withAmount:_comInfo.price withSessionSid:[[RvcNetWork shared] nextSessionID]];
    }
}

- (void)parseOrderPaymentResponse:(TcpResponse *)response{
    if (kOrderPaymentResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        [[UIWaitView sharedClient] hideLoading];
        [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        return;
    }
    
    [[UIWaitView sharedClient] showPopUpView:@"支付成功" withImage:@"success" complement:^{
        HWScanViewController * hwScanVC = [[HWScanViewController alloc] init];
        hwScanVC.orderid = _orderInfo.orderId;
        [self.navigationController pushViewController:hwScanVC animated:YES];
    }];
}

- (void)parseComUserBalanceList:(TcpResponse*)response{
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
        [[UIWaitView sharedClient] hideLoading];
        [[UIWaitView sharedClient] showPopUpView:message withImage:@"alert.png" complement:^{
            [[RvcNetWork shared] getUserBalanceWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
        }];
        return;
    }
    yue = [data doubleValue];
    if (yue >= _comInfo.price) {
        _stylePayView.hidden = YES;
        _stylePayHeightCons.constant = 0.0;
    }
    _balanceLb.text = [NSString stringWithFormat:@"￥%.2f",yue];
}

- (void)parseAfterModifyUserInfo:(TcpResponse*)response{
    if (kGetUserInfoResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        [[UIWaitView sharedClient] hideLoading];
        [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        return;
    }
    RefineUserInfo * reUserInfo = data;
    if (reUserInfo) {
        [[UIData sharedClient] removeDataObjForKey:@"kUserInfoData"];
    }
    [[UIData sharedClient] append:reUserInfo withKey:@"kUserInfoData"];
}

- (void)parseComModifyUserInfoResponse:(TcpResponse *)response{
    if (kModifyUserInfoResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        [[UIWaitView sharedClient] hideLoading];
        [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
        return;
    }
    [[UIWaitView sharedClient] showPopUpView:@"客户资料修改成功" withImage:@"success" complement:^{
        [[RvcNetWork shared] queryUserDataWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
        //TODO: 下单
        [[RvcNetWork shared] orderLoginId:[UIData sharedClient].loginID withServeId:_comInfo.serviceId withPrice:_comInfo.price withDiscount:1.0 withQuantity:1 withAmount:_comInfo.price withSessionSid:[[RvcNetWork shared] nextSessionID]];
    }];
}

- (void)backComOrderAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)contactCustomerAction:(id)sender {
}

#pragma mark 支付按钮事件响应
- (IBAction)payAction:(id)sender {
    if ([self checkDataComple]) {
        if ([self checkUserDataChange]) {
            [[UIWaitView sharedClient] showPopUpView:@"是否保存客户资料更改信息" withImage:@"alert" complement:^{
                RefineUserInfo * info = [[RefineUserInfo alloc] init];
                info.sex = _sexSelIndex;
                info.carNo = _carNoTf.text;
                info.name = _cusNameLb.text;
                info.parkSlot = _parkingTf.text;
                info.parkType = 0;
                [[RvcNetWork shared] userInfoModWithLoginId:[UIData sharedClient].loginID withUserInfo:info withSessionSid:[[RvcNetWork shared] nextSessionID]];
            }];
        }else{
            [[RvcNetWork shared] orderLoginId:[UIData sharedClient].loginID withServeId:_comInfo.serviceId withPrice:_comInfo.price withDiscount:1.0 withQuantity:1 withAmount:_comInfo.price withSessionSid:[[RvcNetWork shared] nextSessionID]];
            
//            if (yue < _comInfo.price) {
//                [[UIWaitView sharedClient] showPopUpView:@"账户余额不足，请充值后再试" withImage:@"tips_confirm" complement:^{
//                    RechargeViewController * rechangeVC = [[RechargeViewController alloc] initWithNibName:@"RechargeViewController" bundle:[NSBundle mainBundle]];
//                    [self.navigationController pushViewController:rechangeVC animated:YES];
//                }];
//            }else{
//                [[RvcNetWork shared] orderPaymentWithLoginId:[UIData sharedClient].loginID withOrderId:_orderInfo.orderId withAmount:_comInfo.price withSessionSid:[[RvcNetWork shared] nextSessionID]];
//            }
        }
    }
    
}

- (IBAction)alipaySelectAction:(id)sender {
}

- (IBAction)morePayWay:(id)sender {
}
- (IBAction)maleSelAction:(id)sender {
    if (_sexSelIndex != 1) {
        _sexSelIndex = 1;
        [self.maleSelBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self.femaleBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    }
}
- (IBAction)femaleAction:(id)sender {
    if (_sexSelIndex != 2) {
        _sexSelIndex = 2;
        [self.femaleBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self.maleSelBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    }
}
- (IBAction)parkingFixAction:(id)sender {
    if (_typeParking != 0) {
        _typeParking = 0;
        [self.parkingFixBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self.parkingTemBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    }
}
- (IBAction)parkingTemAction:(id)sender {
    if (_typeParking != 1) {
        _typeParking = 1;
        [self.parkingFixBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
        [self.parkingTemBtn setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
    }
}
@end
