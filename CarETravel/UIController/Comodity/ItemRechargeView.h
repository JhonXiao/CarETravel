//
//  ItemRechargeView.h
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/18.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^optionSelectBlo)(NSInteger selIndex);

@interface ItemRechargeView : UIView
@property (weak, nonatomic) IBOutlet UILabel *orginPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *realPriceLb;
- (IBAction)rechargeItemAction:(id)sender;
@property (nonatomic, assign) BOOL selectIf;//默认为NO
@property (nonatomic, assign) NSInteger indexOption;
@property (nonatomic, copy) optionSelectBlo bloOption;

@end
