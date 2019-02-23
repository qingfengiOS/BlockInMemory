//
//  ViewController.m
//  BlockInMemory
//
//  Created by liyiping on 2019/2/23.
//  Copyright © 2019年 情风. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

typedef void(^TestBlock)(int a);
@interface ViewController ()
@property (nonatomic, strong) TestBlock strongBlock;
@property (nonatomic, weak) TestBlock weakBlock;
@property (nonatomic, copy) TestBlock copyBlock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self blockType];
    
    [self blockInMemory];
}

#pragma mark - Block类型
- (void)blockType {
    [self NSMallocBlock];
    [self NSStaticBlock];
    [self NSGlobalBlock];
    /*
     结论： Block也是一个对象，有着自己的继承体系
     */
}

- (void)NSMallocBlock {
    int tempInt = 1;
    void (^block)(void) = ^ {
        NSLog(@"----------%d----------\n\n",tempInt);
    };
    block();
    [self printBlockSuperClass:block];
    //继承体系：__NSMallocBlock__ -> __NSMallocBlock -> NSBlock -> NSObject
}

- (void)NSStaticBlock {
    int tempInt = 1;
    __weak void (^block)(void) = ^ {
        NSLog(@"----------%d----------\n\n",tempInt);
    };
    block();
    
    [self printBlockSuperClass:block];
    //继承体系：__NSStackBlock__ -> __NSStackBlock -> NSBlock -> NSObject
}

- (void)NSGlobalBlock {
    void (^block)(int a) = ^ (int a){
        NSLog(@"----------%d----------\n\n",a);
    };
    block(1);
    
    [self printBlockSuperClass:block];
    //继承体系：__NSGlobalBlock__ -> __NSGlobalBlock -> NSBlock -> NSObject
}

- (void)printBlockSuperClass:(id)block {
    Class class = object_getClass(block);
    NSLog(@"%@",class);
    Class superClass = class_getSuperclass(class);
    while (superClass) {
        NSLog(@"%@",superClass);
        superClass = class_getSuperclass(superClass);
    }
}
#pragma mark - Block的内存
/*
 1、没有外部变量时，三种Block都是 __NSGlobalBlock__
 2、有外部变量时
    2.1 外部变量时全局变量、全局静态变量、局部静态变量时：__NSGlobalBlock__ （全局区）
    2.2 外部变量时普通外部变量：copy和strong修饰的Block是 __NSMallocBlock__（堆区）；weak修饰的block是__NSStackBlock__（栈区）
 */

/*
 有普通外部变量的block是在栈区创建的，当有copy和strong修饰符修饰的时，会把block从栈移到堆区。
 
 由此可得出结论：ARC下使用copy和strong关键字修饰block是一样的。
 */
int globalInt = 1000;//全局变量
static staticInt = 10000;//全局静态变量

- (void)blockInMemory {
    static tempStaticInt = 100000;//局部静态变量
    int normalInt = 20000;
    _strongBlock = ^(int tempInt) {
        NSLog(@"tempInt = %d", normalInt);
    };
    _weakBlock = ^(int tempInt) {
        NSLog(@"tempInt = %d", normalInt);
    };
    _copyBlock = ^(int tempInt) {
        NSLog(@"tempInt = %d", normalInt);
    };
    NSLog(@"\nstrongBlock:%@\n_weakBlock:%@\n_copyBlock:%@",object_getClass(_strongBlock),object_getClass(_weakBlock),object_getClass(_copyBlock));
}


@end
