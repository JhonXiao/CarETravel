//
//  MyOrderTableViewCell.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/16.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "MyOrderTableViewCell.h"

@implementation MyOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _orderStatusBtn.layer.cornerRadius = 3.0;
    _orderStatusBtn.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cancleOrderAction:(id)sender {
    self.bloCancel(0);
}
@end
