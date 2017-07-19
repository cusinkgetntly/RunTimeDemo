//
//  ViewController.m
//  RunTimeTestDemo
//
//  Created by xuchaoqi on 2017/7/19.
//  Copyright © 2017年 MS. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+MultiDelegate.h"
#import "NSObject+KVO.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //RunTime实现归档和反归档
    Person *person1 = [[Person alloc]init];
    person1.name = @"jack";
    person1.age = 18;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:person1];
    Person *person2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"%@",person2.name);
    
    //实用Runtime实现多播委托
//    Person *person = [Person new];
//    [person addDelegate:self];
//    //调用代理方法
//    [person performSelector:NSSelectorFromString(@"doSomething") withObject:nil];
//    [person performSelector:NSSelectorFromString(@"doSomethingMore") withObject:nil];
    
    
    //使用runtime实现kvo
//    Person *person = [[Person alloc]init];
    //给对象添加观察者
//    [person addObserver:self forKey:@"name" withBlock:^(id observerObject, NSString *key, id oldValue, id newValue) {
//        NSLog(@"oldValue=%@",oldValue);
//        NSLog(@"newValue=%@",newValue);
//    }];
//    
//    person.name = @"张三";
//    person.name = @"李四";
//    person.specPro = @"test";
//    NSLog(@"person.specPro=%@",person.specPro);
//    [person performSelector:@selector(eat)];

    
}


- (void)doSomething{
    NSLog(@"doSomething");
}

- (void)doSomethingMore{
    NSLog(@"doSomethingMore");
}



@end
