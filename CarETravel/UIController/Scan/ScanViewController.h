//
//  ScanViewController.h
//  CarETravel
//
//  Created by yg on 2017/5/16.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^tabbarSelectBlo)(NSUInteger sel);

@interface ScanViewController : UIViewController

@property (nonatomic, copy) tabbarSelectBlo tabbarBlo;
@end
