//
//  ObjectController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/4/4.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "ObjectController.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "NSBook.h"
#import "RunTimeClass.h"
@interface ObjectController ()

@end

@implementation ObjectController



#define ISA_MASK        0x0000000ffffffff8ULL

struct NSObject_IMPL {
    Class isa;
};

struct NSBook_IMPL {
    struct NSObject_IMPL NSObject_IVARS;
    NSInteger _page;
};



/*
 在终端执行
 xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc NSBook.m -o NSBook.cpp
 发现对象转成了一个名为NSBook_IMPL的类，NSBook_IMPL又包含NSObject_IVARS，NSObject_IVARS里面只有一个元素Class类型的isa指针
 也就是实际上所有继承NSObject的类本质第一个元素都是isa指针，占8个字节

 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //实例对象
    NSBook *b = [[NSBook alloc] init];
    b.page = 100;
    [b read];
    
    //查看下实例对象和b指针指向内存的大小
    NSLog(@"%zd %zd",class_getInstanceSize([NSBook class]),malloc_size((__bridge const void *)b));
    

    struct NSBook_IMPL *book_impl = (__bridge struct NSBook_IMPL *)b;
    NSLog(@"实例对象isa指针 = %p",book_impl->NSObject_IVARS.isa);
    
    
    //类对象
    Class cls = [NSBook class];
    NSLog(@"类对象地址 %p",cls);
    
    //获取元类对象
    Class metaCls = object_getClass([NSBook class]);
    NSLog(@"元类对象地址 %p",metaCls);
    

    uint64_t b_address = (uint64_t)(book_impl->NSObject_IVARS.isa) & ISA_MASK;
    //两个值相等，同理可以lldb调试取出类对象的前八个字节isa指针 &mask 后发现等于元类对象的地址
    NSLog(@"%d",b_address == (uint64_t)cls);
    
    
    //查看runTime源码我们可以获得类对象和元类对象的底层结构，我们可以自己构造一个跟类对象或者元类对象相同的结构体，通过断点，可以非常清晰的知道类对象和元类对象的底层结构
    
    struct run_objc_class *run_cls = (__bridge struct run_objc_class *)(cls);
    struct run_objc_class *meta_cls = (__bridge struct run_objc_class *)(metaCls);
    
    
    class_rw_t* cls_rw_t = run_cls->data();
    
    class_rw_t* cls_rw_meta = meta_cls->data();
    
    
    
}

/*
 OC对象分三种:实例对象，类对象、元类对象.实例对象可以有多个，类对象和元类对象只有一份，并且一直存在，不会被销毁。
 每一个对象的第一个成员其实都是isa，64位以前是直接一个指针，实例对象的isa指向类对象，类对象的isa指向元类对象，64位后isa是一个union,存着类和对象的更多信息。需要通过位运算找到类对象或者元类对象地址:
     类对象地址 = 实例对象->isa & ISA_MASK
     元类对象地址 = 类对象->isa & ISA_MASK
 实例对象本身没有方法，类对象和元类对象包含了实例方法和类方法，通过ISA指针进行关联，可以找到方法调用。如果本类没有，在通过superClass从父类找，方法调用具体实现由RunTime管理和实现。
 
 其中，对象方法、属性、成员变量、协议信息，存放在class对象中(class_rw_t类中)
 类方法，存放在meta-class对象中(class_rw_t类中)
 成员变量的具体值，存放在instance对象
 
 */


@end
