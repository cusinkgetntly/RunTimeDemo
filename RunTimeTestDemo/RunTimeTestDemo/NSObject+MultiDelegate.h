//
//  NSObject+MultiDelegate.h
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/14.
//  Copyright © 2017年 MS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MultiDelegate)
- (void)addDelegate:(id)delegate;
- (void)removeDelegete:(id)delegate;
@end
