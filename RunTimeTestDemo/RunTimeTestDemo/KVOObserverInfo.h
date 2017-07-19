//
//  KVOObserverInfo.h
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/17.
//  Copyright © 2017年 MS. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ObserverBlock)(id,NSString *,id,id);
@interface KVOObserverInfo : NSObject
// 观察者属性
@property (nonatomic, weak) id observer;
// key属性
@property (nonatomic, copy) NSString *key;
// 回调block
@property (nonatomic, copy) ObserverBlock block;

- (instancetype)initWithObserver:(id)observer forKey:(NSString *)key withBlock:(ObserverBlock)block;
@end
