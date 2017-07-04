//
//  CustomServiceVC.h
//  CarETravel
//
//  Created by yg on 2017/4/26.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^tabbarSelectBlo)(NSUInteger sel);

@interface CustomServiceVC : UIViewController

@property (nonatomic, copy) tabbarSelectBlo tabbarBlo;

@end
