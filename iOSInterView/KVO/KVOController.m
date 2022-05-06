//
//  KVOController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/4/5.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "KVOController.h"
#import "NSBookAA.h"
#import <objc/runtime.h>
@interface KVOController ()

@property (nonatomic, strong) NSBookAA *book1;

@property (nonatomic, strong) NSBookAA *book2;

@end

@implementation KVOController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.book1 = [[NSBookAA alloc] init];
    //self.book1.page = 1;
    
    self.book2 = [[NSBookAA alloc] init];
    self.book1.size = 2;
    
    // 给person1对象添加KVO监听
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.book1 addObserver:self forKeyPath:@"page" options:options context:nil];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    // NSKVONotifying_NSBookAA是使用Runtime动态创建的一个类，是NSBookAA的子类
    // self.person1.isa == NSKVONotifying_NSBookAA
    [self.book1 setPage:1];
    
    NSLog(@"self.book1.superclass %@",object_getClass(self.book1).superclass); //NSBookAA
    NSLog(@"self.book2.superclass %@",object_getClass(self.book2).superclass); //NSObject
    
    
    //使用KVO后其实self.book1的isa指针并不是指向自己的类对象，而是系统新建的一个NSKVONotifying_NSBookAA 对象
    //所以这个observeValueForKeyPath的调用全在子类NSKVONotifying_NSBookAA完成，并且重写了部分方法
    
    //手动触发KVO ？
    //调用 willChangeValueForKey 和didChangeValueForKey
    
}

// 当监听对象的属性值发生改变时，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"KVO %@的%@ - %@ - %@", object, keyPath, change, context);
}



@end
