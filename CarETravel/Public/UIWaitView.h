//
//  UIWaitView.h
//  YongWeiPan
//
//  Created by revenco on 16/12/23.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromptView.h"

typedef void (^OkBlo)(NSInteger sel);//1表示选中取消按钮，2 表示选中确定按钮

typedef void(^PopUpViewBlock)();

typedef void (^SelectBlo)(NSInteger sel);//1表示选中取消按钮，0 表示选中确定按钮

@interface UIWaitView : NSObject

@property (nonatomic, copy) OkBlo okSelBlo;
@property (nonatomic, copy) PopUpViewBlock popUpBlo;
@property (nonatomic, copy) SelectBlo selBlo;

+ (UIWaitView *)sharedClient;

- (void)showLoading:(NSString *)text withImage:(NSString *)imageName;
- (void)hideLoading;

- (void)showPrompt:(NSString*)text withImage:(NSString*)imgName;
- (void)hidePrompt;

- (void)showCanSelectPrompt:(NSString *)text withImage:(NSString *)imgName withItem:(NSString *)cancel withItem2:(NSString *)ok;

- (void)showBlockCanSelectPrompt:(NSString *)text withImage:(NSString *)imgName withItem:(NSString *)ok withItem2:(NSString *)cancel complement:(SelectBlo)finnishBlo;

- (void)hideCanSelectPromptView;

- (void)showPopUpView:(NSString *)text withImage:(NSString *)imgName complement:(PopUpViewBlock)finnishBlo;

@end
