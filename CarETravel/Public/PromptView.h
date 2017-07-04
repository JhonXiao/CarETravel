//
//  PromptView.h
//  YongWeiPan
//
//  Created by revenco on 16/12/26.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIButton *iconPrompt;
@property (weak, nonatomic) IBOutlet UILabel *promptLb;
- (IBAction)okBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end
