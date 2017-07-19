//
//  NSObject+KVO.m
//  NSTimerTest
//
//  Created by xuchaoqi on 2017/7/17.
//  Copyright © 2017年 MS. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/objc-runtime.h>
#import "KVOObserverInfo.h"
@implementation NSObject (KVO)

static NSString *const KVOClassPrefix = @"XC";
static char KVOServerAssociatedKey;

- (void)setSpecPro:(NSString *)specPro{
    objc_setAssociatedObject(self, @"specPro", specPro, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)specPro{
    return objc_getAssociatedObject(self, @"specPro");
}

- (void)addObserver:(id)observer forKey:(NSString *)key withBlock:(void (^)(id, NSString *, id, id))block{
    //获取setterName
    NSString *setName = setterName(key);
    SEL setSelector = NSSelectorFromString(setName);
    //通过SEL获取方法
    Method setMethod = class_getInstanceMethod(object_getClass(self), setSelector);
    if (!setMethod) {
        @throw [NSException exceptionWithName:@"KVO Error" reason:@"没有setter方法，无法KVO" userInfo:nil];
    }
    
    //创建当前的类
    //判断是否已经创建了衍生类
    
    Class thisClass = object_getClass(self);
    NSString *thisClassName = NSStringFromClass(thisClass);
    if (![thisClassName hasPrefix:KVOClassPrefix]) {
        thisClass  = [self makeKVOClassWithOriginalClassName:thisClassName];
        //改变类的标示
        object_setClass(self, thisClass);
    }
    
//    NSLog(@"%@",NSStringFromClass(self.class));
    //判断衍生类是否实现了setter方法
    if (![self hasSelector:setSelector]) {
        const char *setType = method_getTypeEncoding(setMethod);
        //自己添加set方法
        class_addMethod(object_getClass(self), setSelector, (IMP)setter, setType);
    }
    
    NSMutableArray *observers = objc_getAssociatedObject(self, &KVOServerAssociatedKey);
    if (!observers) {
        observers = [NSMutableArray new];
        objc_setAssociatedObject(self, &KVOServerAssociatedKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    //创建观察者info类
    KVOObserverInfo *info = [[KVOObserverInfo alloc]initWithObserver:observer forKey:key withBlock:block];
    [observers addObject:info];
}

- (void)removeObserver:(NSObject *)observer forKey:(NSString *)key{

}

//重写setter方法，新的setter在调用原来的setter方法后，通知每个观察者（调用之前传入的block）
void setter(id objc_self,SEL cmd_p,id newValue){
    //setterName 转为 name
    NSString *setName = NSStringFromSelector(cmd_p);
    NSString *key = nameWithSetterName(setName);
    //通过kvc获取key对应的value
    id oldValue = [objc_self valueForKey:key];
    //将setter消息转发给父类
    struct objc_super selfSuper = {
        .receiver = objc_self,
        .super_class = class_getSuperclass(object_getClass(objc_self))
    };
    //新版方法不带参数，这里只要在Buid Settings中搜索msg，将其修改成NO就可以了
    objc_msgSendSuper(&selfSuper,cmd_p,newValue);
    
    //调用block
    NSMutableArray *observers = objc_getAssociatedObject(objc_self, &KVOServerAssociatedKey);
    for (KVOObserverInfo *info in observers) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([info.key isEqualToString:key]) {
                info.block(objc_self, key, oldValue, newValue);
            }
        });
    }
}

// 从setterName转回name
NSString *nameWithSetterName(NSString *setName)
{
    if (setName.length <= 4 || ![setName hasPrefix:@"set"] || ![setName hasSuffix:@":"]) {
        @throw [NSException exceptionWithName:@"KVO Error" reason:@"set方法not available" userInfo:nil];
    }
    NSString *Name = [setName substringWithRange:NSMakeRange(3, setName.length - 4)];
    NSString *firstCharacter = [Name substringToIndex:1];
    return [[firstCharacter lowercaseString]   stringByAppendingString:[Name substringFromIndex:1]];
}

//在衍生类中判断set方法是否存在
- (BOOL)hasSelector:(SEL)aSelector{
    unsigned int mCount = 0;
    Method *methods = class_copyMethodList(object_getClass(self), &mCount);
    
    for (int i = 0; i < mCount; i++) {
        Method method = methods[i];
        SEL setSelector = method_getName(method);
        if (setSelector == aSelector) {
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

//runtime创建类
- (Class)makeKVOClassWithOriginalClassName:(NSString *)className{
    NSString *kvoClassName = [KVOClassPrefix stringByAppendingString:className];
    Class KVOClass = NSClassFromString(kvoClassName);
    if (KVOClass) {
        return KVOClass;
    }
    //objc_allocateClasspair创建类
    KVOClass = objc_allocateClassPair([self class], kvoClassName.UTF8String, 0);
//    NSLog(@"%@",NSStringFromClass(KVOClass));
    return KVOClass;
}

NSString *setterName(NSString *key){
    if (key.length == 0) {
        @throw [NSException exceptionWithName:@"KVO Error" reason:@"没有对应的key" userInfo:nil];
    }
    NSString *firstCharacter = [key substringToIndex:1];
    NSString *Name = [[firstCharacter uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
    return [NSString stringWithFormat:@"set%@:", Name];
    
}
@end
