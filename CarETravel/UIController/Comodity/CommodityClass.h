//
//  CommodityClass.h
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/8.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommodityClass : NSObject<NSCoding>

@property (nonatomic, assign) int32_t loginID;
@property (nonatomic, assign) int32_t serveId;
@property (nonatomic, assign) int32_t quantity;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double discount;
@property (nonatomic, assign) double amount;

@end
