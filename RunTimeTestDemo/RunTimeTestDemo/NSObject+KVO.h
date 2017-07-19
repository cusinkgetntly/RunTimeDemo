//
//  NSObject+KVO.h
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/17.
//  Copyright © 2017年 MS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVO)

@property (nonatomic , copy)NSString *specPro;


//添加观察者
- (void)addObserver:(id)observer forKey:(NSString *)key withBlock:(void(^)(id,NSString *,id,id))block;
//移除观察者
- (void)removeObserver:(NSObject *)observer forKey:(NSString *)key;
@end
