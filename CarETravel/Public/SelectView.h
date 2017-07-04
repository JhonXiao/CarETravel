//
//  SelectView.h
//  CarETravel
//
//  Created by xiaoliwu on 2017/4/7.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectView;
//回调  pickerView 回传类本身 用来做调用 销毁动作
//     choiceString  回传选择器 选择的单个条目字符串
typedef void(^selectPickerViewBlock)(SelectView *pickerView,NSString *choiceString);

@interface SelectView : UIView
@property (nonatomic,copy)selectPickerViewBlock callBack;

//------单条选择器
+(instancetype)ZYSheetStringPickerWithTitle:(NSArray *)title andHeadTitle:(NSString *)headTitle Andcall:(selectPickerViewBlock)callBack;
//显示
-(void)show;
//销毁类
-(void)dismissPicker;

@end
