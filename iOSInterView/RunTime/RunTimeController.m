//
//  RunTimeController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/1.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "RunTimeController.h"
#import <objc/runtime.h>
#import "NSBookAE.h"
@interface RunTimeController ()

@end

@implementation RunTimeController


- (void)isa
{
    
    //每个OC对象第一个成员都是isa，从arm64开始，isa是一个union，采用位域存储更多的元素
    
    union isa_t
    {
        Class cls;
        uintptr_t bits;
        struct {
            uintptr_t nonpointer        : 1; // 0 代表普通的指针，存储着Class、Meta-Class对象的内存地址
            //1，代表优化过，使用位域存储更多的信息
 
            uintptr_t has_assoc         : 1;  //是否有设置过关联对象

            uintptr_t has_cxx_dtor      : 1;  //是否有C++的析构函数（.cxx_destruct）

            uintptr_t shiftcls          : 33; // Class、Meta-Class对象的内存地址信息

            uintptr_t magic             : 6;   //调试相关
            uintptr_t weakly_referenced : 1;   // 是否有被弱引用指向过
            uintptr_t deallocating      : 1;   //对象是否正在释放

            uintptr_t has_sidetable_rc  : 1;   //引用计数器是否过大无法存储在isa中 如果为1，那么引用计数会存储在一个叫SideTable的类的属性中
            
            uintptr_t extra_rc          : 19; //里面存储的值是引用计数器减1

        };
    };
    
}

- (void)run_class
{
    //类对象 或者元类对象结构如下:
    // 通过Runtime源码得知 方法  属性  协议列表主要是存在 class_rw_t 并且都是可读可写，
    // 是一个二维数组,结构如下
    // arry = [[method_list],[method_list]]
    // method_list = [method_t,method_t];
    
    //只读的class_ro_t 存放的是类的一些初始化信息，成员变量等等，方法，协议，成员就是一个method list
    
    
    
    //method_t结构如下:
    struct method_t {
        SEL name;  //方法名字
        const char *types; //编码，参数，返回值类型  这个具体可以查看@encode的指令相关文档
        IMP imp; //指向函数的指针，就是函数调用地址
        
    };
    
    //SEL代表方法\函数名，一般叫做选择器，底层结构跟char *类似
    //可以通过@selector()和sel_registerName()获得
    //可以通过sel_getName()和NSStringFromSelector()转成字符串
    //不同类中相同名字的方法，所对应的方法选择器是相同的
    
    //结构体中还有个方法缓存（cache_t），用散列表（哈希表）来缓存曾经调用过的方法，可以提高方法的查找速度


}

- (void)callFun
{
   // OC中的方法调用，其实都是转换为objc_msgSend函数的调用
    
   // objc_msgSend的执行流程可以分为3大阶段 1 消息发送 2 动态方法解析 3 消息转发
    
    //比如本方法调用 [self callFun]
    // objc_msgSend(self, @selector(callFun));
    // 消息接收者（receiver）：self
    // 消息名称：callFun
    
    
    
    // 消息发送流程如下:
    //根据objc_send汇编 当x0就是一个参数receiver 为Nil的时候，直接返回0,
    //先从receiverClass中缓存找，如果找不到，在class_rw_t中找，如果没找到从父类缓存中查找，如果找不到则从父类的class_rw_t中找，如果还有父类继续找，如果找到了会把相应的方法缓存下来，并调用，如果还是找不到，则进入方法的动态解析
    
    //在clss_rw_t中查找方法的时候，如果已经排序的方法，二分查找，如果是没有排序的方法，直接遍历查找
    
    
    

}


- (void)test
{
    NSLog(@"test");
}

//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//        if (sel == @selector(resolve)) {
//            // 获取其他方法
//            Method m = class_getInstanceMethod(self, @selector(test));
//
//            // 动态添加test方法的实现
//
//            const char *encode = method_getTypeEncoding(m);
//            NSLog(@"%s",encode);
//
//            class_addMethod(self, sel, method_getImplementation(m),  encode);
//
//            // 返回YES代表有动态添加方法
//            return YES;
//        }
//        return [super resolveInstanceMethod:sel];
//}


//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//
//    // 如果没有实现动态方法解析，消息会来到  forwardingTargetForSelector
//    if (aSelector == @selector(resolve)) {
//        return [[NSBookAE alloc] init];
//        // objc_msgSend([[NSBookAE alloc] init], aSelector)
//        //相当于把aSelector 转发到这个对象
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}


// 方法签名：返回值类型、参数类型
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if (aSelector == @selector(resolve)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:i"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation_test:(id)object
{
    NSLog(@"forwardInvocation_test");
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    
    
    // NSInvocation封装了一个方法调用，包括：方法调用者、方法名、方法参数
    //    anInvocation.target 方法调用者
    //    anInvocation.selector 方法名
    //    [anInvocation getArgument:NULL atIndex:0]
    
    //  这里可以处理转发消息的任何逻辑
    
    
    anInvocation.target = [[NSBookAE alloc] init];
    
    int age  = 10;
    [anInvocation setArgument:&age atIndex:2]; //在转发这个消息的时候，添加一个参数
    
    anInvocation.selector = @selector(NSBookAE_forward:);
    [anInvocation invoke];

}

- (void)msg
{
    //动态方法解析
    
    [self resolve];
    
}

- (void)super_call
{
    
    //super的实际调用，底层会转换为objc_msgSendSuper2函数的调用，接收2个参数
//    struct objc_super2 {
//        id receiver; //消息接受者
//        Class current_class;//receiver的class对象，但是方法会从current_class的superClass开始搜索
//    };
//
//    objc_msgSendSuper2(objc_super2, @selector);
    

    NSBookAE *b = [[NSBookAE alloc] init];
    [b read];
    
}



//- (BOOL)isMemberOfClass:(Class)cls {
//    return [self class] == cls;
//}
//
//- (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}




- (void)type
{
    // 这句代码的方法调用者不管是哪个类（只要是NSObject体系下的），都返回YES,因为所有的类的包括元类对象的superClass 根类都是 [NSObject class]
    NSLog(@"%d", [NSObject isKindOfClass:[NSObject class]]); // 1
    
    
    NSLog(@"%d", [NSObject isMemberOfClass:[NSObject class]]); // 0
    NSLog(@"%d", [NSBookAE isKindOfClass:[NSBookAE class]]); // 0
    NSLog(@"%d", [NSBookAE isMemberOfClass:[NSBookAE class]]); // 0
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self isa];
    [self run_class];
    [self callFun];
    
    [self msg];
    
    [self super_call];
    
    [self type];
    
    //runtime 应用：利用runtimeAPI  动态创建类，遍历类属性或者成员变量 ，
    //动态添加，替换方法，访问类的私有成员变量
    
    
    
    
    
    
    
}



@end
