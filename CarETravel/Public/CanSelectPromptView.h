//
//  CanSelectPromptView.h
//  YongWeiPan
//
//  Created by xiaoliwu on 2017/1/12.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanSelectPromptView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIButton *headImgBnt;
@property (weak, nonatomic) IBOutlet UILabel *tipLb;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
- (IBAction)okAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
- (IBAction)cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *tipView;

@end
