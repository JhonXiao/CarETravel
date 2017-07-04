//
//  MyOrderTableViewCell.h
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/16.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CancelOrderBlo)(int64_t);

@interface MyOrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderOpenTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *carModelLb;
@property (weak, nonatomic) IBOutlet UILabel *allPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *serviceItemLb;
@property (weak, nonatomic) IBOutlet UILabel *estimatedFinshTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *orderNoLb;
@property (weak, nonatomic) IBOutlet UIButton *orderStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *gridIdLb;
@property (weak, nonatomic) IBOutlet UILabel *gridInfoLb;
- (IBAction)cancleOrderAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderBtn;
@property (copy, nonatomic) CancelOrderBlo bloCancel;

@end
