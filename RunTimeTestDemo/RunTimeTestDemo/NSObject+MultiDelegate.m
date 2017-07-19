//
//  NSObject+MultiDelegate.m
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/14.
//  Copyright © 2017年 MS. All rights reserved.
//

#import "NSObject+MultiDelegate.h"
#import <objc/objc-runtime.h>
NSString *const kMultiDelegatekey = @"multiDelegatekey";
@implementation NSObject (MultiDelegate)

- (void)addDelegate:(id)delegate{
    /*
       我们可以把关联对象想象成一个Objective-C对象(如字典)，这个对象通过给定的key连接到类的一个实例上。不过由于使用的是C接口，所以key是一个void指针(const void *)。我们还需要指定一个内存管理策略，以告诉Runtime如何管理这个对象的内存。
     */
    // 设置代理数组，为对象关联对象
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMultiDelegatekey));
    //如果当前对象没有关联的数组，创建并且设置
    if (!delegateArray) {
        delegateArray = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)(kMultiDelegatekey), delegateArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    //添加到数组
    [delegateArray addObject:delegate];
}



- (void)removeDelegete:(id)delegate{
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMultiDelegatekey));
    if (!delegateArray) {
        @throw [NSException exceptionWithName:@"MultiDelegate error" reason:@"数组不能为空" userInfo:nil];
    }
    [delegateArray removeObject:delegate];
}

- (void)doNothing{
    
}

// 消息转发
/*
    消息转发机制使用从下面这个方法中获取的信息来创建NSInvocation对象。因此我们必须重写这个方法，为给定的selector提供一个合适的方法签名。
 */
// 获取方法标识
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMultiDelegatekey));
    for (id aDelegate in delegateArray) {
        NSMethodSignature *sig = [aDelegate methodSignatureForSelector:aSelector];
        if (sig) {
            return sig;
        }
    }
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

/*
 运行时系统会在这一步给消息接收者最后一次机会将消息转发给其它对象。对象会创建一个表示消息的NSInvocation对象，把与尚未处理的消息有关的全部细节都封装在anInvocation中，包括selector，目标(target)和参数。我们可以在forwardInvocation方法中选择将消息转发给其它对象。
 */
// 消息转发给其他对象
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMultiDelegatekey));
    for (id aDelegate in delegateArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 异步转发消息
            [anInvocation invokeWithTarget:aDelegate];
        });
    }
    
}

@end
