//
//  CommodityClass.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/8.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "CommodityClass.h"

@implementation CommodityClass

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.loginID = [[aDecoder decodeObjectForKey:@"loginID"] intValue];
        self.serveId = [[aDecoder decodeObjectForKey:@"serviceID"] intValue];
        self.quantity = [[aDecoder decodeObjectForKey:@"quantity"] intValue];
        self.price = [[aDecoder decodeObjectForKey:@"price"] doubleValue];
        self.discount = [[aDecoder decodeObjectForKey:@"discount"] doubleValue];
        self.amount = [[aDecoder decodeObjectForKey:@"amount"] doubleValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSNumber numberWithInt:self.loginID] forKey:@"loginID"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.serveId] forKey:@"serviceID"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.quantity] forKey:@"quantity"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.price] forKey:@"price"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.discount] forKey:@"discount"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.amount] forKey:@"amount"];
}

@end
