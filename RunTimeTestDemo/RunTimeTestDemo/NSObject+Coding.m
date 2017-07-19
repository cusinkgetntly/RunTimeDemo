//
//  NSObject+Coding.m
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/14.
//  Copyright © 2017年 MS. All rights reserved.
//

#import "NSObject+Coding.h"
#import <objc/objc-runtime.h>

@implementation NSObject (Coding)
//遍历类中的所有实例变量，逐个进行归档和反归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    unsigned int ivarCount = 0;
    /*
        class_copyIvarList函数，它返回一个指向成员变量信息的数组，数组中每个元素是指向该成员变量信息的objc_ivar结构体的指针。这个数组不包含在父类中声明的变量。outCount指针返回数组的大小。需要注意的是，我们必须使用free()来释放这个数组。
     */
    Ivar *vars = class_copyIvarList(object_getClass(self), &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        Ivar var = vars[i];
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        //KVC
        id value = [self valueForKey:varName];
        //归档
        [aCoder encodeObject:value forKey:varName];
    }
    
    free(vars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    if (self) {
        //遍历实例变量链表，逐个进行反归档
        unsigned int ivarCount = 0;
        Ivar *vars = class_copyIvarList(object_getClass(self), &ivarCount);
        for (int i = 0; i < ivarCount; i++) {
            Ivar var = vars[i];
            NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
            //反归档
            id value = [aDecoder decodeObjectForKey:varName];
            //KVC
            [self setValue:value forKey:varName];
        }
        free(vars);
    }
    return self;
}
@end
