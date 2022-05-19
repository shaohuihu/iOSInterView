//
//  BlockController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/1.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "BlockController.h"
#import "NSBookAD.h"

@interface BlockController ()
@end


typedef void(^block3)(void);
@implementation BlockController

/* block本质也是一个OC对象，它内部也有个isa指针，只是他是封装了OC函数调用环境的OC对象 */



- (void)block1
{
    int age = 20;
    void(^block)(void) = ^{
        //age = 100;//这里报错
        NSLog(@"age is %d",age);
    };
    
    block();
    
    
    //xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc BlockController.m  -o BlockController.cpp
    //以上代码用clang转换后提取block代码如下:
    
    /*
     
     struct __block_impl {
     void *isa;
     int Flags;
     int Reserved;
     void *FuncPtr;
     };
     
     struct __BlockController__viewDidLoad_block_impl_0 {
     struct __block_impl impl;
     struct __BlockController__viewDidLoad_block_desc_0* Desc;
     int age;
     __BlockController__viewDidLoad_block_impl_0(void *fp, struct __BlockController__viewDidLoad_block_desc_0 *desc, int _age, int flags=0) : age(_age) {
     impl.isa = &_NSConcreteStackBlock;
     impl.Flags = flags;
     impl.FuncPtr = fp;
     Desc = desc;
     }
     };
     static void __BlockController__viewDidLoad_block_func_0(struct __BlockController__viewDidLoad_block_impl_0 *__cself) {
     int age = __cself->age; // bound by copy
     
     NSLog((NSString *)&__NSConstantStringImpl__var_folders_yx_x0n54cd97rb9jb777qy7pncm0000gq_T_BlockController_80bdcc_mi_0,age);
     }
     
     static struct __BlockController__viewDidLoad_block_desc_0 {
     size_t reserved;
     size_t Block_size;
     } __BlockController__viewDidLoad_block_desc_0_DATA = { 0, sizeof(struct __BlockController__viewDidLoad_block_impl_0)};
     
     static void _I_BlockController_viewDidLoad(BlockController * self, SEL _cmd) {
     ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("BlockController"))}, sel_registerName("viewDidLoad"));
     
     int age = 20;
     void(*block)(void) = ((void (*)())&__BlockController__viewDidLoad_block_impl_0((void *)__BlockController__viewDidLoad_block_func_0, &__BlockController__viewDidLoad_block_desc_0_DATA, age));
     
     ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
     }
     
     
     分析如下:
     从这里看出void(*block)(void) = ((void (*)())&__BlockController__viewDidLoad_block_impl_0
     __BlockController__viewDidLoad_block_impl_0 这里是构造函数，初始化block，第一个参数是函数指针，以后调用的时候，实际也是调用的这个函数指针，第二个参数是block的desc信息包括大小这些。第三个参数是捕获的外界变量，当前这里直接是指传递。所以block内部调用的时候，函数指针无法找到以前变量的地址，导致无法修改，也就是常见的在block内部直接修改报错的原因，需要通过一些其他手段。
     
     */
}

- (void)block2
{
    int age1 = 30;
    int *age = &age1;
    void(^block)(void) = ^{
        *age = 100;  //这里捕获的就是局部变量的指针，这种方式就可以修改age  同理，如果是static变量，也是捕获的地址，因为static变量只有一份内存，全局变量的话，直接访问，直接读写。
        NSLog(@"age is %d",*age);
    };
    
    block();
    NSLog(@"执行完block");
    NSLog(@"执行完block age is %d",*age);
    
    
    //其block结构如下
    /*
    struct __BlockController__viewDidLoad_block_impl_0 {
        struct __block_impl impl;
        struct __BlockController__viewDidLoad_block_desc_0* Desc;
        int *age;
        __BlockController__viewDidLoad_block_impl_0(void *fp, struct __BlockController__viewDidLoad_block_desc_0 *desc, int *_age, int flags=0) : age(_age) {
            impl.isa = &_NSConcreteStackBlock;
            impl.Flags = flags;
            impl.FuncPtr = fp;
            Desc = desc;
        }
    };
     
     */
    
}

- (void)block3
{
    void (^block1)(void) = ^{
        NSLog(@"Hello"); //__NSGlobalBlock__
    };
    
    int age = 10;
    void (^block2)(void) = ^{
        NSLog(@"Hello - %d", age);
    };  //这里是 __NSMallocBlock__ 是因为在ARC环境下[block2 class] block2是强指针
    //这里会调用copy操作，将栈block拷贝到堆上
    
    NSLog(@"%@ %@ %@", [block1 class], [block2 class], [^{
       NSLog(@"Hello - %d", age); //__NSStackBlock__ 这里不会调用copy操作
    } class]);
    
    
    //总结:block再调用copy后，栈上的block会拷贝到堆上，堆中的block调用copy后引用计数加1，全局block调用copy不做任何操作
    
    //在ARC环境下，编译器会根据情况自动将栈上的block复制到堆上，比如以下情况
    //block作为函数返回值时
    //将block赋值给__strong指针时
    //block作为Cocoa API中方法名含有usingBlock的方法参数时
    //block作为GCD API的方法参数时
    
   
    
    
    {
        NSBookAD *ac = [[NSBookAD alloc] init];
        void(^block4)(void) = ^{
            NSLog(@"Hello - %ld", (long)ac.page);
        };
        NSLog(@"block4 %@",[block4 class]);  //在ARC环境下，这里是堆block MRC环境下，
        //这是栈block 离开大括号后无论是ARC还是MRC都会被销毁
        block4();
    }
    
    
    
    block3 b;

    {
        NSBookAD *ac = [[NSBookAD alloc] init];
        b = ^{
            NSLog(@"Hello - %ld", (long)ac.page);
        };
        NSLog(@"block3 %@",[b class]);

    }
    
    //ARC: 离开大括号后，block是堆block，虽然NSBookAD 已经离开作用域，但是block对其强引用，NSBookAD不会dealloc
    // MRC: block 是栈block，离开作用域后NSBookAD会挂掉，栈block不会对auto变量强引用，如果将block调用copy则能保住NSBookAD对象
    
    
    
    /*
     总结:
    当block内部访问了对象类型的auto变量时
    如果block是在栈上，将不会对auto变量产生强引用
    
    如果block被拷贝到堆上
    会调用block内部的copy函数
    copy函数内部会调用_Block_object_assign函数
    _Block_object_assign函数会根据auto变量的修饰符（__strong、__weak、__unsafe_unretained）做出相应的操作，形成强引用（retain）或者弱引用
    
    如果block从堆上移除
    会调用block内部的dispose函数
    dispose函数内部会调用_Block_object_dispose函数
    _Block_object_dispose函数会自动释放引用的auto变量（release）
     */

    
    
  
    
    
    
    
    
}


- (void)block4
{
    __block int fs = 100;
    void(^block5)(void) = ^{
        NSLog(@"block5 - %d", fs);
    };
    block5();
    
    //clang如下
    
    
    /*
    
    struct __Block_byref_fs_0 {
        void *__isa;
        __Block_byref_fs_0 *__forwarding;
        int __flags;
        int __size;
        int fs;
    };
    
    struct __BlockController__block4_block_impl_0 {
        struct __block_impl impl;
        struct __BlockController__block4_block_desc_0* Desc;
        __Block_byref_fs_0 *fs; // by ref
        __BlockController__block4_block_impl_0(void *fp, struct __BlockController__block4_block_desc_0 *desc, __Block_byref_fs_0 *_fs, int flags=0) : fs(_fs->__forwarding) {
            impl.isa = &_NSConcreteStackBlock;
            impl.Flags = flags;
            impl.FuncPtr = fp;
            Desc = desc;
        }
    };
     
     */
    
    //通过block修饰的变量会转换成一个struct类型，包含isa和以前捕获的变量，转换成这样的结构体后，内部可以修改以前的类型，因为类型其实已经被block修改成了指针类型
    
    //通过__block修饰的变量捕获后的结构体有一个指针叫__forwarding  当调用block后找到最原始的的变量都是通过这个指针，这个指针指向__Block_byref_fs_0，当block在栈中的时候，这个指针指向栈中的block，当block在堆上的时候，这个指针指向堆中的block，因为很多block在符合条件下会copy，保证这个指针指向的内存合法
    
    
    
    __block NSBookAD * aaad = [[NSBookAD alloc] init];
    void(^block6)(void) = ^{
        NSLog(@"block6 - %ld", (long)aaad.page);
    };
    block6();
    
    //  当block在栈上时，对它们都不会产生强引用
    
//    当block拷贝到堆上时，都会通过copy函数来处理它们
//    __block变量（假设变量名叫做a）
//    _Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);
//
//    对象类型的auto变量（假设变量名叫做p）
//    _Block_object_assign((void*)&dst->p, (void*)src->p, 3/*BLOCK_FIELD_IS_OBJECT*/);
//
//    当block从堆上移除时，都会通过dispose函数来释放它们
//    __block变量（假设变量名叫做a）
//    _Block_object_dispose((void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);
//
//    对象类型的auto变量（假设变量名叫做p）
//    _Block_object_dispose((void*)src->p, 3/*BLOCK_FIELD_IS_OBJECT*/);
    
    
    
    
//    当__block变量在栈上时，不会对指向的对象产生强引用
//
//    当__block变量被copy到堆时
//    会调用__block变量内部的copy函数
//    copy函数内部会调用_Block_object_assign函数
//    _Block_object_assign函数会根据所指向对象的修饰符（__strong、__weak、__unsafe_unretained）做出相应的操作，形成强引用（retain）或者弱引用（注意：这里仅限于ARC时会retain，MRC时不会retain）
//
//    如果__block变量从堆上移除
//    会调用__block变量内部的dispose函数
//    dispose函数内部会调用_Block_object_dispose函数
//    _Block_object_dispose函数会自动释放指向的对象（release）

    

    
    
}

- (void)block5
{
    
    
    {
        
        //循环引用 这里会产生循环引用，对象都不会销毁
        //对象强引用block 而block 强引用对象
        //这里其实只要用weak 修饰对象，这样block捕获的变量是weak类型，不会对原对象产生强引用
        
        
        NSBookAD * aaad = [[NSBookAD alloc] init];
        aaad.page = 100;
        aaad.block = ^(int number) {
            NSLog(@"%d",aaad.page);
        };
        
        
        
        
        //用_weak解决循环引用
        //clang查看 xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 BlockController.m
        
        //结构如下：
        //        struct __BlockController__block5_block_impl_1 {
        //            struct __block_impl impl;
        //            struct __BlockController__block5_block_desc_1* Desc;
        //            NSBookAD *__weak aaad3;
        //        }
        
        NSBookAD * aaad2 = [[NSBookAD alloc] init];
        __weak  NSBookAD * aaad3 = aaad2;
        aaad3.page = 100;
        aaad3.block = ^(int number) {
            NSLog(@"%ld",(long)aaad3.page);
        };
        
        
        //用block也可以解决循环引用的问题
        //用block捕获后相互引用如下:
        
        //__block变量强引用对象，对象强引用block，block强引用内部捕获的__block变量 形成三角环引用
        //此时可以在调用block后将对象设置成nil 断掉环中的一条数据，则环就会断开 不会存在引用循环
        
        __block NSBookAD * aaad4 = [[NSBookAD alloc] init];
        aaad4.page = 100;
        aaad4.block = ^(int number) {
            NSLog(@"%ld",(long)aaad4.page);
            aaad4 = nil;
        };
        aaad4.block(10);
        
        //MRC：没有__weak  可以用__unsafe_unretained 和__block 修饰也能解决循环引用，MRC中block变量对外界对象不会产生强引用
        
        
        
        
    }
    
    NSLog(@"block5  end");
   
    
    
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self block1];
//    [self block2];
    [self block3];
//
//
//    [self block4];
    
//    [self block5];

    
    
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}





@end
