//
//  ComOrderViewController.h
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/16.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TcpResponse.h"

@interface ComOrderViewController : UIViewController

@property (nonatomic, retain) ServiceListInfo * comInfo;
@property (nonatomic, retain) UserOrderInfo * orderInfo;
@end
