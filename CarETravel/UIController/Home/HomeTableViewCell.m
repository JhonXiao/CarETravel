//
//  HomeTableViewCell.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/14.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "HomeTableViewCell.h"

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _orderBtn.layer.cornerRadius = 3.0;
    _orderBtn.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)orderAction:(id)sender {
    self.block(_comInfo);
}

@end
