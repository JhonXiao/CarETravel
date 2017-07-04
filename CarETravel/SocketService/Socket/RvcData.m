//
//  RvcData.m
//  RvcNetwork
//
//  Created by revenco on 14-6-10.
//  Copyright (c) 2014年 sunrise. All rights reserved.
//

#import "RvcData.h"

@implementation RvcData

+ (RvcData *)shared {
    __strong static RvcData *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RvcData alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
	if((self = [super init]))
	{
        theMethodCacheQueue = [[NSMutableArray alloc] init];
        theKeyCacheQueue = [[NSMutableArray alloc] init];
        theDataMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -  Data Methods with key
///////////////////////////////////////////////////////////////////////////////////////////////////////////

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

- (void)appendCacheWithKey:(NSString *)key useBlock:(void (^)(id cache, NSError *error))block
{
    NSMutableArray *tmp = (NSMutableArray *)[self dataObjWithKey:key];
    if (tmp && [tmp count]>0)
    {
        for (id obj in tmp)
        {
            [theKeyCacheQueue addObject:obj];
        }
    }
    block( theKeyCacheQueue, nil );
    
    NSMutableArray *array = [theKeyCacheQueue copy];
    [self append:array withKey:key];
//    [array release];
    [self dataKeyCacheClear];
}

- (void)dataKeyCacheClear
{
    // BAD
    if ([theKeyCacheQueue count] > 0) {
        [theKeyCacheQueue removeAllObjects];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -  Data Methods with method-code
///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)append:(id)data withMethod:(int)method
{
    NSString *key = [NSString stringWithFormat:@"%d",method];
    NSAssert(data, key, @"data != NULL, key is not NULL");
    [theDataMap setObject:data forKey:key];
}

- (void)removeDataObjForMethod:(int)method
{
    NSString *key = [NSString stringWithFormat:@"%d",method];
    NSAssert(key, @"key != NULL");
    [theDataMap removeObjectForKey:key];
}

- (id)dataObjWithMethod:(int)method
{
    NSString *key = [NSString stringWithFormat:@"%d",method];
    NSAssert(key, @"key != NULL");
    return [theDataMap objectForKey:key];
}

- (void)appendCacheWithMethod:(int)method useBlock:(void (^)(id cache, NSError *error))block
{
    NSMutableArray *tmp = (NSMutableArray *)[self dataObjWithMethod:method];
    
//    NSLog(@"%@",tmp);
    
    if (tmp && [tmp count]>0)
    {
        for (id obj in tmp)
        {
            [theMethodCacheQueue addObject:obj];
        }
    }
    block( theMethodCacheQueue, nil );
    
    NSMutableArray *array = [theMethodCacheQueue copy];
    [self append:array withMethod:method];
//    [array release];
    [self dataMethodCacheClear];
}

- (void)dataMethodCacheClear
{
    if ([theMethodCacheQueue count] > 0) {
        [theMethodCacheQueue removeAllObjects];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -  Data Methods with clear cache
///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)clearMap
{
    if ([theDataMap count] > 0) {
        [theDataMap removeAllObjects];
    }
}

- (void)clearAll
{
    [self dataMethodCacheClear];
    [self dataKeyCacheClear];
    [self clearMap];
}

@end
