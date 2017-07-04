//
//  ItemRechargeView.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/18.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ItemRechargeView.h"

@implementation ItemRechargeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
//    self.layer.borderColor = [UIColor colorWithRed:252.0/255 green:154.0/255 blue:20.0/255 alpha:1.0].CGColor;
//    self.layer.borderWidth = 1.0;
}

- (IBAction)rechargeItemAction:(id)sender {
    self.bloOption(_indexOption);
}

@end
