//
//  HomeTableViewCell.h
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/14.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TcpResponse.h"
typedef void(^Blo)(ServiceListInfo*);

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *styleLB;
@property (weak, nonatomic) IBOutlet UIButton *headerImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *secTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *descLb;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;
- (IBAction)orderAction:(id)sender;
@property (nonatomic, copy) Blo block;
@property (nonatomic, retain) ServiceListInfo * comInfo;

@end
