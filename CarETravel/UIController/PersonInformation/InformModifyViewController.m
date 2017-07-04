//
//  InformModifyViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/4/6.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "InformModifyViewController.h"
#import "UIData.h"
#import "RvcNetWork.h"
#import "UIWaitView.h"
#import "Config.h"
#import "UICode.h"
#import "MainViewController.h"

@interface InformModifyViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,NetSocketDelegate,UITextFieldDelegate>{
    NSMutableArray * pickerDatasource;
    UIView * _selectView;
    UIPickerView * pickerView;
    NSString * _currentSelStr;
    NSInteger _currentSelRow;
    RefineUserInfo * getReUserInfo;
    NSMutableArray * carBandInfoArray;
    NSMutableArray * carTypeInfoArray;
    int32_t _sendCarBandId;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
- (IBAction)carNoModAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *carNoLb;
@property (weak, nonatomic) IBOutlet UITextField *sexTf;
- (IBAction)sexSelectAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *carNoTf;
- (IBAction)hideKeyboardAction:(id)sender;
- (IBAction)hideKeyboardCon:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *parkSlotTf;
@property (weak, nonatomic) IBOutlet UITextField *bandTf;
@property (weak, nonatomic) IBOutlet UITextField *cartypeTf;
@property (weak, nonatomic) IBOutlet UITextField *colorTf;
- (IBAction)selectBandAction:(id)sender;
- (IBAction)selectCarTypeAction:(id)sender;

@end

@implementation InformModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem* saveBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = saveBarItem;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"修改资料";
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backInformModAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 150)];
    _selectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_selectView];
    
    UIButton * okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(_selectView.frame.size.width - 60, 5, 50, 20);
    [okBtn setTitle:@"完成" forState:0];
    [okBtn setTitleColor:[UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1.0] forState:0];
    [_selectView addSubview:okBtn];
    [okBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 5, 50, 20);
    [cancelBtn setTitle:@"取消" forState:0];
    [cancelBtn setTitleColor:[UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1.0] forState:0];
    [_selectView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, _selectView.frame.size.width, 120)];
    pickerView.backgroundColor = [UIColor clearColor];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [_selectView addSubview:pickerView];
    
    _carNoTf.delegate = self;
    _parkSlotTf.delegate = self;
    _nameTf.delegate = self;
    _bandTf.delegate = self;
    _cartypeTf.delegate = self;
    
    _sendCarBandId = 0;//初始化当前发送的汽车品牌的id为0
}

- (void)tfPlaceHolderSet{
    NSString * str = @"请输入车牌号码(格式:粤A00000)";
    // 创建 NSMutableAttributedString
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置字体和设置字体的范围
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:14.0f]
                    range:NSMakeRange(0, str.length)];
    _carNoTf.attributedPlaceholder = attrStr;
    
    str = @"停车位置(格式:X区X层XXXX位)";
    NSMutableAttributedString *attrStrPark = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置字体和设置字体的范围
    [attrStrPark addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:14.0f]
                    range:NSMakeRange(0, str.length)];
    _parkSlotTf.attributedPlaceholder = attrStrPark;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:_nameTf]) {
        _nameTf.text = @"";
    }else if ([textField isEqual:_carNoTf]){
        _carNoTf.text = @"";
    }else if ([textField isEqual:_parkSlotTf]){
        _parkSlotTf.text = @"";
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [self tfPlaceHolderSet];
    
    pickerDatasource = [[NSMutableArray alloc] init];
    
    getReUserInfo = [[UIData sharedClient] dataObjWithKey:@"kUserInfoData"];
    _carNoTf.text = getReUserInfo.carNo;
    _nameTf.text = getReUserInfo.name;
    _parkSlotTf.text = getReUserInfo.parkSlot;
    if (getReUserInfo.sex == 0) {
        _sexTf.text = @"先生/女士";
    }else if (getReUserInfo.sex == 1){
        _sexTf.text = @"先生";
    }else if (getReUserInfo.sex == 2){
        _sexTf.text = @"女士";
    }
    
    [RvcNetWork shared].response = self;
    [[RvcNetWork shared] queryCarBandWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    
}

- (void)cancelAction{
    [self dismissPicker];
}

- (void)okAction{
    if (pickerView.tag == 211) {
        _sexTf.text = [pickerDatasource objectAtIndex:_currentSelRow];
    }else if (pickerView.tag == 212){
        _bandTf.text = [pickerDatasource objectAtIndex:_currentSelRow];
    }else if (pickerView.tag == 213){
        _cartypeTf.text = [pickerDatasource objectAtIndex:_currentSelRow];
    }
    [self dismissPicker];
}

- (void)tfResign{
    [_nameTf resignFirstResponder];
    [_carNoTf resignFirstResponder];
    [_parkSlotTf resignFirstResponder];
}

- (void)backInformModAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction{
    RefineUserInfo * info = [[RefineUserInfo alloc] init];
//    @"先生/女士",@"先生",@"女士",
    if ([_sexTf.text isEqualToString:@"先生/女士"]) {
        info.sex = 0;
    }else if ([_sexTf.text isEqualToString:@"先生"]){
        info.sex = 1;
    }else{
        info.sex = 2;
    }
    info.carNo = _carNoTf.text;
    info.name = _nameTf.text;
    info.parkSlot = _parkSlotTf.text;
    info.parkType = 0;
    for (CartypeInfomation * infoType in carTypeInfoArray) {
        if ([_cartypeTf.text isEqualToString:infoType.cartypeName]) {
            info.carType = infoType.cartypeId;
        }
    }
    info.carColor = _colorTf.text;
    info.dispCarType = @"";
    if ([_carNoTf.text isEqualToString:@""]) {
        [[UIWaitView sharedClient] showPrompt:@"车牌号不能为空" withImage:@"alert"];
        return;
    }else if ([_nameTf.text isEqualToString:@""]){
        [[UIWaitView sharedClient] showPrompt:@"姓名不能为空" withImage:@"alert"];
        return;
    }else if ([_parkSlotTf.text isEqualToString:@""]){
        [[UIWaitView sharedClient] showPrompt:@"停车位置不能为空" withImage:@"alert"];
        return;
    }else if ([_bandTf.text isEqualToString:@"请选择汽车品牌"]){
        [[UIWaitView sharedClient] showPrompt:@"请选择汽车品牌" withImage:@"alert"];
        return;
    }else if ([_cartypeTf.text isEqualToString:@"请选择汽车型号"]){
        [[UIWaitView sharedClient] showPrompt:@"请选择汽车型号" withImage:@"alert"];
        return;
    }
    [self tfResign];
    
    [[RvcNetWork shared] userInfoModWithLoginId:[UIData sharedClient].loginID withUserInfo:info withSessionSid:[[RvcNetWork shared] nextSessionID]];
}

#pragma mark netSocketClient
- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseModifyUserInfoResponse:data];
        [self parseAfterModifyUserInfo:data];
        [self parseCarBandResponse:data];
        [self parseCarTypeResponse:data];
    });
}

- (void)parseCarBandResponse:(TcpResponse *)response{
    if (kGetCarBandResponse != response.tag)
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
    [[UIData sharedClient] append:data withKey:@"kCarBandInfo"];
    carBandInfoArray = [NSMutableArray arrayWithArray:data];
}

- (void)parseCarTypeResponse:(TcpResponse *)response{
    if (kGetCarTypeResponse != response.tag)
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
    if (!data) {
        [[UIWaitView sharedClient] showPrompt:@"当前汽车品牌下无可供选择的汽车型号" withImage:@"alert.png"];
        return;
    }
    NSString * carTypeSaveStr = [NSString stringWithFormat:@"kCarTypeInfo%d",_sendCarBandId];
    [[UIData sharedClient] append:data withKey:carTypeSaveStr];
    carTypeInfoArray = [NSMutableArray arrayWithArray:data];
    
    [pickerDatasource removeAllObjects];
    for (CartypeInfomation * infoType in carTypeInfoArray) {
        [pickerDatasource addObject:infoType.cartypeName];
    }
    [pickerView reloadAllComponents];
    
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        _selectView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 150 - 64, [UIScreen mainScreen].bounds.size.width, 150);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)parseModifyUserInfoResponse:(TcpResponse *)response{
    if (kModifyUserInfoResponse != response.tag)
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
    [[UIWaitView sharedClient] showPopUpView:@"保存成功" withImage:@"success" complement:^{
        [[RvcNetWork shared] queryUserDataWithLoginId:[UIData sharedClient].loginID withSessionSid:[[RvcNetWork shared] nextSessionID]];
    }];
}

- (void)parseAfterModifyUserInfo:(TcpResponse*)response{
    if (kGetUserInfoResponse != response.tag)
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
    RefineUserInfo * reUserInfo = data;
    if (reUserInfo) {
        [[UIData sharedClient] removeDataObjForKey:@"kUserInfoData"];
    }
    [[UIData sharedClient] append:reUserInfo withKey:@"kUserInfoData"];
    if (_fromVC == 1) {
        MainViewController * mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:mainVC animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 分隔线
- (IBAction)carNoModAction:(id)sender {
}

- (IBAction)sexSelectAction:(id)sender {
    [_nameTf resignFirstResponder];
    [_carNoTf resignFirstResponder];
    pickerDatasource = [NSMutableArray arrayWithObjects:@"先生/女士",@"先生",@"女士", nil];
    [pickerView reloadAllComponents];
    pickerView.tag = 211;
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        _selectView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 150 - 64, [UIScreen mainScreen].bounds.size.width, 150);
    } completion:^(BOOL finished) {

    }];
}

- (void)dismissPicker{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        _selectView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 150);
    } completion:^(BOOL finished) {
        
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerDatasource.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    _currentSelStr = [pickerDatasource objectAtIndex:row];
    _currentSelRow = row;
}

// UIPickerViewDelegate中定义的方法，该方法返回的NSString将作为UIPickerView
// 中指定列和列表项的标题文本
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // 由于该控件只包含一列，因此无须理会列序号参数component
    // 该方法根据row参数返回teams中的元素，row参数代表列表项的编号，
    // 因此该方法表示第几个列表项，就使用teams中的第几个元素
    
    return [pickerDatasource objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30.0;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* l = [[UILabel alloc] init];
    l.font =  [UIFont systemFontOfSize:15.0];
    l.textColor = [UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1.0];
    l.textAlignment = NSTextAlignmentCenter;
    l.text = pickerDatasource[row];
    return l;
}

- (IBAction)hideKeyboardAction:(id)sender {
    [_nameTf resignFirstResponder];
    [_carNoTf resignFirstResponder];
    [_parkSlotTf resignFirstResponder];
    [_bandTf resignFirstResponder];
    [_cartypeTf resignFirstResponder];
    [_colorTf resignFirstResponder];
}

- (IBAction)hideKeyboardCon:(id)sender {
    [_nameTf resignFirstResponder];
    [_carNoTf resignFirstResponder];
    [_parkSlotTf resignFirstResponder];
    [_bandTf resignFirstResponder];
    [_cartypeTf resignFirstResponder];
    [_colorTf resignFirstResponder];
}
- (IBAction)selectBandAction:(id)sender {
    [pickerDatasource removeAllObjects];
    for (CarBandInfomation * infoBand in carBandInfoArray) {
        [pickerDatasource addObject:infoBand.bandName];
    }
    [pickerView reloadAllComponents];
    pickerView.tag = 212;

    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        _selectView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 150 - 64, [UIScreen mainScreen].bounds.size.width, 150);
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)selectCarTypeAction:(id)sender {
    if ([_bandTf.text isEqualToString:@"请选择汽车品牌"]) {
        [[UIWaitView sharedClient] showPrompt:@"请选择汽车品牌" withImage:@"alert"];
        return;
    }
    for (CarBandInfomation * infoBand in carBandInfoArray) {
        if ([_bandTf.text isEqualToString:infoBand.bandName]) {
            _sendCarBandId = infoBand.bandId;
            break;
        }
    }
    if (_sendCarBandId == 0) {
        [[UIWaitView sharedClient] showPrompt:@"找不到对应的汽车品牌的id" withImage:@"alert"];
        return;
    }
    [[RvcNetWork shared] queryCarTypeWithLoginId:[UIData sharedClient].loginID withCarBand:_sendCarBandId withSessionSid:[[RvcNetWork shared] nextSessionID]];
    pickerView.tag = 213;
}
@end
