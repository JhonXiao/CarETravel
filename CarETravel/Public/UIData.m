//
//  UIData.m
//  NetClient
//
//  Created by sunrise on 14-3-7.
//  Copyright (c) 2014年 com.sunrise. All rights reserved.
//

#import "UIData.h"

#define DATAQUEUE_CAPACITY 5

@implementation UIData

+ (UIData *)sharedClient {
    __strong static UIData *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UIData alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
	if((self = [super init]))
	{
        theCacheQueue = [[NSMutableArray alloc] init];
        theUICacheQueue = [[NSMutableArray alloc] init];
        theDataMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)append:(id)data withKey:(NSString *)key
{
    NSAssert(data, key, @"data != NULL, key is not NULL");
    [theDataMap setObject:data forKey:key];
}

- (id)dataObjWithKey:(NSString *)key
{
    NSAssert(key, @"key != NULL");
    return [theDataMap objectForKey:key];
}

- (void)removeDataObjForKey:(NSString *)key
{
    NSAssert(key, @"key != NULL");
    [theDataMap removeObjectForKey:key];
}

- (void)append:(id)data withMethod:(int)method
{
    NSString *desc = [NSString stringWithFormat:@"%d",method];
    NSAssert(data, desc, @"data != NULL, desc is not NULL");
    [theDataMap setObject:data forKey:desc];
}

- (id)dataObjWithMethod:(int)method
{
    NSString *desc = [NSString stringWithFormat:@"%d",method];
    NSAssert(desc, @"desc != NULL");
    return [theDataMap objectForKey:desc];
}

- (void)appendCacheWithMethod:(int)method useBlock:(void (^)(id cache, NSError *error))block
{
    NSMutableArray *tmp = (NSMutableArray *)[self dataObjWithMethod:method];
    if (tmp && [tmp count]>0) {
        for (id obj in tmp) {
            [theCacheQueue addObject:obj];
        }
    }
    block( theCacheQueue, nil );
    
    NSMutableArray *array = [theCacheQueue copy];
    [self append:array withMethod:method];
    [array release];
    [self dataCacheClear];
}

- (void)appendCacheWithKey:(NSString *)key useBlock:(void (^)(id cache, NSError *error))block
{
    NSMutableArray *tmp = (NSMutableArray *)[self dataObjWithKey:key];
    if (tmp && [tmp count]>0) {
        for (id obj in tmp) {
            [theUICacheQueue addObject:obj];
        }
    }
    block( theUICacheQueue, nil );
    
    NSMutableArray *array = [theUICacheQueue copy];
    [self append:array withKey:key];
    [array release];
    [self dataUICacheClear];
}

- (void)dataCacheClear
{
    if ([theCacheQueue count] > 0) {
        [theCacheQueue removeAllObjects];
    }
}

- (void)dataUICacheClear
{
    // BAD
    if ([theUICacheQueue count] > 0) {
        [theUICacheQueue removeAllObjects];
    }
}

- (void)clear
{
    if ([theDataMap count] > 0) {
        [theDataMap removeAllObjects];
    }
}

- (void)clearAll
{
    [self dataCacheClear];
    [self dataUICacheClear];
    [self clear];
}

@end
