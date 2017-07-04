//
//  SelectView.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/4/7.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#define KScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "SelectView.h"

@interface SelectView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak,nonatomic)UIView *bgView;    //屏幕下方看不到的view
@property (weak,nonatomic)UILabel *titleLabel; //中间显示的标题lab
@property (weak, nonatomic) UIPickerView *pickerView;
@property (weak,nonatomic)UIButton *cancelButton;
@property (weak,nonatomic)UIButton *doneButton;
@property (strong,nonatomic)NSArray *dataArray;   // 用来记录传递过来的数组数据
@property (strong,nonatomic)NSString *headTitle;  //传递过来的标题头字符串
@property (strong,nonatomic)NSString *backString; //回调的字符串

@end

@implementation SelectView

+ (instancetype)ZYSheetStringPickerWithTitle:(NSArray *)title andHeadTitle:(NSString *)headTitle Andcall:(selectPickerViewBlock)callBack{
    SelectView *pickerView = [[SelectView alloc] initWithFrame:[UIScreen mainScreen].bounds  andTitle:title andHeadTitle:headTitle];
    pickerView.callBack = callBack;
    return pickerView;
}

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSArray*)title andHeadTitle:(NSString *)headTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = title;
        _headTitle = headTitle;
        _backString = self.dataArray[0];
//        [self setupUI];
    }
    return self;
}

- (void)dismissPicker{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        self.frame = CGRectMake(0, SCREEN_SIZE.height, KScreenWidth, 150);
    } completion:^(BOOL finished) {
        
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataArray.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    _currentSelStr = [pickerDatasource objectAtIndex:row];
}

// UIPickerViewDelegate中定义的方法，该方法返回的NSString将作为UIPickerView
// 中指定列和列表项的标题文本
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // 由于该控件只包含一列，因此无须理会列序号参数component
    // 该方法根据row参数返回teams中的元素，row参数代表列表项的编号，
    // 因此该方法表示第几个列表项，就使用teams中的第几个元素
    
    return [self.dataArray objectAtIndex:row];
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
    l.text = self.dataArray[row];
    return l;
}

@end
