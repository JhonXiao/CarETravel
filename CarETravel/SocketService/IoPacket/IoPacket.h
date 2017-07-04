//
//  IoPacket.h
//  NetSocketLib
//
//  Created by revenco on 13-11-7.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility_Protected.h"
//packet
@interface IoPacket : NSObject

@property (nonatomic, assign)    header_t Header;
@property (nonatomic, retain)    NSData *Body;
@property (nonatomic, retain)    NSString *Sid;

- (header_t)buildHeaderWith:(NSInteger)command WithLength:(int)length;
- (id)initWithCmd:(NSInteger)command WithBody:(NSData*)body WithSid:(NSString *)sid;
- (NSInteger) getOp;

@end
