//
//  RvcData.h
//  RvcNetwork
//
//  Created by revenco on 14-6-10.
//  Copyright (c) 2014年 sunrise. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface RvcData : NSObject
{
    NSMutableArray *theMethodCacheQueue;
    NSMutableArray *theKeyCacheQueue;
    NSMutableDictionary *theDataMap;
}

- (id)init;

+ (RvcData *)shared;

- (void)append:(id)data withKey:(NSString *)key;
- (id)dataObjWithKey:(NSString *)key;
- (void)removeDataObjForKey:(NSString *)key;
- (void)appendCacheWithKey:(NSString *)key useBlock:(void (^)(id cache, NSError *error))block;
- (void)dataKeyCacheClear;

- (void)append:(id)data withMethod:(int)method;
- (id)dataObjWithMethod:(int)method;
- (void)removeDataObjForMethod:(int)method;
- (void)appendCacheWithMethod:(int)method useBlock:(void (^)(id cache, NSError *error))block;
- (void)dataMethodCacheClear;

- (void)clearMap;
- (void)clearAll;

@end
