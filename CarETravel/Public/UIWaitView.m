//
//  UIWaitView.m
//  YongWeiPan
//
//  Created by revenco on 16/12/23.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import "UIWaitView.h"
#import <UIKit/UIKit.h>
#import "Config.h"
#import "CanSelectPromptView.h"

@interface UIWaitView(){
    UIView * tipView;
    PromptView * _promptView;
    CanSelectPromptView * _canSelectPromptView;
    CanSelectPromptView * _canSelectPromptViewBlock;
    PromptView * _popupFinishView;
}

@end

@implementation UIWaitView

+ (UIWaitView *)sharedClient {
    __strong static UIWaitView *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UIWaitView alloc] init];
    });
    
    return _sharedClient;
}

- (void)showLoading:(NSString *)text withImage:(NSString *)imageName{
    if (tipView) {
        [self hideLoading];
    }
    tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kUIScreenWidth, kUIScreenHeight)];
    tipView.backgroundColor = [UIColor clearColor];
//    tipView.alpha = 0.7;
    UIView * backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kUIScreenWidth, kUIScreenHeight)];
    backGroundView.backgroundColor = [UIColor lightGrayColor];
    backGroundView.alpha = 0.7;
    [tipView addSubview:backGroundView];
    
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.center = [[UIApplication sharedApplication] keyWindow].center;
    backView.layer.cornerRadius = 5.0;
    backView.clipsToBounds = YES;
    backView.backgroundColor = [UIColor colorWithRed:31.0/255 green:132.0/255 blue:254.0/255 alpha:1];
    [tipView addSubview:backView];
    
    UIImageView * loadingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50 - 16, 10, 32, 30)];
    loadingImgView.image = [UIImage imageNamed:imageName];
    [backView addSubview:loadingImgView];
    
    UILabel * showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 100, 40)];
    showLabel.textAlignment = NSTextAlignmentCenter;
    showLabel.textColor = [UIColor whiteColor];
    showLabel.text = text;
    showLabel.numberOfLines = 0;
    showLabel.font = [UIFont systemFontOfSize:14.0];
    [backView addSubview:showLabel];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:tipView];
    tipView.layer.zPosition = INT8_MAX;
}

- (void)showCanSelectPrompt:(NSString *)text withImage:(NSString *)imgName withItem:(NSString *)cancel withItem2:(NSString *)ok{
    _canSelectPromptView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CanSelectPromptView class]) owner:self options:nil].lastObject;
    _canSelectPromptView.frame = CGRectMake(0, 0, screen_width, screen_height);
    
    _canSelectPromptView.tipView.layer.cornerRadius = 5.0;
    _canSelectPromptView.tipView.clipsToBounds = YES;
    
    _canSelectPromptView.backView.backgroundColor = [UIColor lightGrayColor];
    _canSelectPromptView.backView.alpha = 0.5;
    
    _canSelectPromptView.tipLb.text = text;
    
    _canSelectPromptView.okBtn.layer.cornerRadius = 5.0;
    _canSelectPromptView.okBtn.clipsToBounds = YES;
    [_canSelectPromptView.okBtn setTitle:ok forState:0];
    [_canSelectPromptView.okBtn addTarget:self action:@selector(okCanAction) forControlEvents:UIControlEventTouchUpInside];
    
    _canSelectPromptView.cancleBtn.layer.cornerRadius = 5.0;
    _canSelectPromptView.cancleBtn.clipsToBounds = YES;
    [_canSelectPromptView.cancleBtn setTitle:cancel forState:0];
    [_canSelectPromptView.cancleBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_canSelectPromptView];
    _canSelectPromptView.layer.zPosition = INT8_MAX;
}

- (void)okCanAction{
    [self hideCanSelectPromptView];
    self.okSelBlo(2);
}

- (void)hideCanSelectPromptView{
    if (_canSelectPromptView) {
        [_canSelectPromptView removeFromSuperview];
        _canSelectPromptView = nil;
    }
}

- (void)cancelAction{
    if (_canSelectPromptView) {
        [_canSelectPromptView removeFromSuperview];
        _canSelectPromptView = nil;
    }
}

- (void)showPrompt:(NSString*)text withImage:(NSString*)imgName{
    if (_promptView) {
        [self hidePrompt];
    }
    _promptView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PromptView class]) owner:self options:nil].lastObject;
    _promptView.frame = CGRectMake(0, 64, screen_width, screen_height - 64);
    _promptView.layer.cornerRadius = 5.0;
    _promptView.clipsToBounds = YES;
    [_promptView.iconPrompt setImage:[UIImage imageNamed:imgName] forState:0];
    
    _promptView.backView.backgroundColor = [UIColor lightGrayColor];
    _promptView.backView.alpha = 0.5;
    
    _promptView.promptLb.text = text;
    
    _promptView.okBtn.layer.cornerRadius = 5.0;
    _promptView.okBtn.clipsToBounds = YES;
    [_promptView.okBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_promptView];
    _promptView.layer.zPosition = INT8_MAX;
}

- (void)okAction{
    [self hidePrompt];
}

- (void)hidePrompt{
    if (_promptView) {
        [_promptView removeFromSuperview];
        _promptView = nil;
    }
}

- (void)hideLoading {
    if (tipView) {
        [tipView removeFromSuperview];
        tipView = nil;
    }
}

- (void)showPopUpView:(NSString *)text withImage:(NSString *)imgName complement:(PopUpViewBlock)finnishBlo{
    _popUpBlo = finnishBlo;
    _popupFinishView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PromptView class]) owner:self options:nil].lastObject;
    _popupFinishView.frame = CGRectMake(0, 64, screen_width, screen_height - 64);
    _popupFinishView.layer.cornerRadius = 5.0;
    _popupFinishView.clipsToBounds = YES;
    
    _popupFinishView.backView.backgroundColor = [UIColor lightGrayColor];
    _popupFinishView.backView.alpha = 0.5;
    
    _popupFinishView.promptLb.text = text;
    
    _popupFinishView.okBtn.layer.cornerRadius = 5.0;
    _popupFinishView.okBtn.clipsToBounds = YES;
    [_popupFinishView.okBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];

    [[[UIApplication sharedApplication] keyWindow] addSubview:_popupFinishView];
    _popupFinishView.layer.zPosition = INT8_MAX;
}

- (void)btnAction{
    _popUpBlo();
    if (_popupFinishView) {
        [_popupFinishView removeFromSuperview];
        _popupFinishView = nil;
    }
}

- (void)showBlockCanSelectPrompt:(NSString *)text withImage:(NSString *)imgName withItem:(NSString *)ok withItem2:(NSString *)cancel complement:(SelectBlo)finnishBlo{
    _selBlo = finnishBlo;
    _canSelectPromptViewBlock = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CanSelectPromptView class]) owner:self options:nil].lastObject;
    _canSelectPromptViewBlock.frame = CGRectMake(0, 0, screen_width, screen_height);
    
    _canSelectPromptViewBlock.tipView.layer.cornerRadius = 5.0;
    _canSelectPromptViewBlock.tipView.clipsToBounds = YES;
    
    _canSelectPromptViewBlock.backView.backgroundColor = [UIColor lightGrayColor];
    _canSelectPromptViewBlock.backView.alpha = 0.5;
    
    _canSelectPromptViewBlock.tipLb.text = text;
    
    _canSelectPromptViewBlock.okBtn.layer.cornerRadius = 5.0;
    _canSelectPromptViewBlock.okBtn.clipsToBounds = YES;
    [_canSelectPromptViewBlock.okBtn setTitle:ok forState:0];
    [_canSelectPromptViewBlock.okBtn addTarget:self action:@selector(destructiveAction) forControlEvents:UIControlEventTouchUpInside];
    
    _canSelectPromptViewBlock.cancleBtn.layer.cornerRadius = 5.0;
    _canSelectPromptViewBlock.cancleBtn.clipsToBounds = YES;
    [_canSelectPromptViewBlock.cancleBtn setTitle:cancel forState:0];
    [_canSelectPromptViewBlock.cancleBtn addTarget:self action:@selector(noAction) forControlEvents:UIControlEventTouchUpInside];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_canSelectPromptViewBlock];
    _canSelectPromptViewBlock.layer.zPosition = INT8_MAX;
}

- (void)destructiveAction{
    _selBlo(0);
    if (_canSelectPromptViewBlock) {
        [_canSelectPromptViewBlock removeFromSuperview];
        _canSelectPromptViewBlock = nil;
    }
}

- (void)noAction{
    _selBlo(1);
    if (_canSelectPromptViewBlock) {
        [_canSelectPromptViewBlock removeFromSuperview];
        _canSelectPromptViewBlock = nil;
    }
}

@end
