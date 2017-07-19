//
//  KVOObserverInfo.m
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/17.
//  Copyright © 2017年 MS. All rights reserved.
//

#import "KVOObserverInfo.h"

@implementation KVOObserverInfo
- (instancetype)initWithObserver:(id)observer forKey:(NSString *)key withBlock:(ObserverBlock)block {
    self = [super init];
    if (self) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end
