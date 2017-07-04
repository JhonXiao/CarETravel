//
//  IoPacket.m
//  NetSocketLib
//
//  Created by revenco on 13-11-7.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#import "IoPacket.h"
//#import "RvcAppDelegate.h"

//static const int VER    = 116;
static const int VENDOR = 20;
static const int MARKET = 10;

@implementation IoPacket
{
    header_t Header;
    NSData *Body;
    NSString *Sid;
}

@synthesize Header,Body,Sid;

- (header_t)buildHeaderWith:(NSInteger)command WithLength:(int)length
{
    header_t rtnHeader;
    memset(&rtnHeader, 0, sizeof(header_t));
//    RvcAppDelegate * rvcDele = (RvcAppDelegate *)[[UIApplication sharedApplication] delegate];
//    rtnHeader.version = rvcDele.VER;
    rtnHeader.version = 100;
    rtnHeader.length = sizeof(header_t)+length;
    rtnHeader.command = command;
    rtnHeader.vendor_id = VENDOR;
    rtnHeader.market = MARKET;
    return rtnHeader;
}

- (id)initWithCmd:(NSInteger)command WithBody:(NSData*)body WithSid:(NSString *)sid
{
    if (self=[super init])
    {
        int bLength = (int)body.length;
        header_t header = [self buildHeaderWith:command WithLength:bLength];
        self.Header = header;
        self.Body = body;
        self.Sid = sid;
    }
    return self;
}

- (NSInteger)getOp
{
    return self.Header.command;
}

- (void)dealloc
{
    Body = nil;
    Sid = nil;
    [super dealloc];
}

@end
