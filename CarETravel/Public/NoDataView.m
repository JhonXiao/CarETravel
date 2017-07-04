//
//  NoDataView.m
//  YongWeiPan
//
//  Created by xiaoliwu on 2017/1/6.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "NoDataView.h"

@implementation NoDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
//    NSLog(@"awakeFromNib nodata");
    _backButton.layer.cornerRadius = 5.0;
    _backButton.clipsToBounds = YES;
}

- (IBAction)backBtnAction:(id)sender {
    if (_dele && [_dele respondsToSelector:@selector(notificationBackResponse)]) {
        [_dele notificationBackResponse];
    }
}

@end
