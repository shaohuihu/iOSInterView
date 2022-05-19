//
//  MemoryController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/14.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "MemoryController.h"
#import "TimerProxy.h"
#import "NSBookAG.h"

#if TARGET_OS_OSX && __x86_64__
// 64-bit Mac - tag bit is LSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
// Everything else - tag bit is MSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif

#define _OBJC_TAG_INDEX_MASK 0x7
// array slot includes the tag bit itself
#define _OBJC_TAG_SLOT_COUNT 16
#define _OBJC_TAG_SLOT_MASK 0xf

#define _OBJC_TAG_EXT_INDEX_MASK 0xff
// array slot has no extra bits
#define _OBJC_TAG_EXT_SLOT_COUNT 256
#define _OBJC_TAG_EXT_SLOT_MASK 0xff

#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1UL<<63)
#   define _OBJC_TAG_INDEX_SHIFT 60
#   define _OBJC_TAG_SLOT_SHIFT 60
#   define _OBJC_TAG_PAYLOAD_LSHIFT 4
#   define _OBJC_TAG_PAYLOAD_RSHIFT 4
#   define _OBJC_TAG_EXT_MASK (0xfUL<<60)
#   define _OBJC_TAG_EXT_INDEX_SHIFT 52
#   define _OBJC_TAG_EXT_SLOT_SHIFT 52
#   define _OBJC_TAG_EXT_PAYLOAD_LSHIFT 12
#   define _OBJC_TAG_EXT_PAYLOAD_RSHIFT 12
#else
#   define _OBJC_TAG_MASK 1UL
#   define _OBJC_TAG_INDEX_SHIFT 1
#   define _OBJC_TAG_SLOT_SHIFT 0
#   define _OBJC_TAG_PAYLOAD_LSHIFT 0
#   define _OBJC_TAG_PAYLOAD_RSHIFT 4
#   define _OBJC_TAG_EXT_MASK 0xfUL
#   define _OBJC_TAG_EXT_INDEX_SHIFT 4
#   define _OBJC_TAG_EXT_SLOT_SHIFT 4
#   define _OBJC_TAG_EXT_PAYLOAD_LSHIFT 0
#   define _OBJC_TAG_EXT_PAYLOAD_RSHIFT 12
#endif


@interface MemoryController ()



@property (strong, nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSString *name;

@end

@implementation MemoryController


- (void)timerMemory
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[TimerProxy proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];
}

- (void)timerTest
{
    NSLog(@"timerTest");
}





static inline bool
_objc_isTaggedPointer(const void * _Nullable ptr)
{
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}


- (void)tagpointer
{
    NSNumber *number1 = @1;
    NSNumber *number2 = @2;
    NSNumber *number3 = @3;
    NSLog(@"%p %p %p",number1,number2,number3);
    
    
    /*
     从64bit开始，iOS引入了Tagged Pointer技术，用于优化NSNumber、NSDate、NSString等小对象的存储
     在没有使用Tagged Pointer之前， NSNumber等对象需要动态分配内存、维护引用计数等，NSNumber指针存储的是堆中NSNumber对象的地址值
     使用Tagged Pointer之后，NSNumber指针里面存储的数据变成了：Tag + Data，也就是将数据直接存储在了指针中
     当指针不够存储数据时，才会使用动态分配内存的方式来存储数据
     objc_msgSend能识别Tagged Pointer，比如NSNumber的intValue方法，直接从指针提取数据，节省了以前的调用开销
     如何判断一个指针是否为Tagged Pointer？
     iOS平台，最高有效位是1（第64bit）
     Mac平台，最低有效位是1
     */
    BOOL result = _objc_isTaggedPointer((__bridge void *)(number1));
    NSLog(@"%d",result);
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            //这里如果不是tagged pointer 并且是nonatomic属性的时候，容易发生崩溃，多线程在release变量的时候容易内存崩溃，这里需要做线程同步
            //self.name = [NSString stringWithFormat:@"abcfffffff安防十大是打发斯蒂芬斯蒂芬"];
        });
    }
    
    
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            //这里不会发生崩溃，因为NSString这里会采用tagged pointer技术存储小对象，不会有retain release操作
            self.name = [NSString stringWithFormat:@"abc"];
        });
    }

}

- (void)retainFun
{
    
    /*
     
     在iOS中，使用引用计数来管理OC对象的内存
     一个新创建的OC对象引用计数默认是1，当引用计数减为0，OC对象就会销毁，释放其占用的内存空间
     调用retain会让OC对象的引用计数+1，调用release会让OC对象的引用计数-1
     内存管理的经验总结
     当调用alloc、new、copy、mutableCopy方法返回了一个对象，在不需要这个对象时，要调用release或者autorelease来释放它
     想拥有某个对象，就让它的引用计数+1；不想再拥有某个对象，就让它的引用计数-1

     */
    
    
    /*
     copy关键字:
     对于可变对象的copy，是拷贝一份不可变的副本，比如NSMutableArray，NSMutableString,NSMutableDictionary等经过copy后变成新的NSArry,NSString,NSDictionary类型，在属性声明中，对于不可变属性用copy关键字，可变属性用strong/retain关键字。
     对于不可变的对象copy，相当于retain，引用计数+1,新对象与老对象地址相同
     对于自定义对象 需要实现copyWithZone方法，具体copy逻辑，可以自己定义
     
     
     深拷贝和浅拷贝:
     浅拷贝是指针拷贝，指向同一块内存
     深拷贝是内容拷贝，内存拷贝 (对于要拷贝的内存中的数据依然是浅拷贝，新内存中里面的数据依然是拷贝之前的数据)
     mutableCopy就是深拷贝,copy可变对象是深拷贝，copy不可变对象是浅拷贝
     
     
     对于属性copy或者stong/retain 其中的set方法转成MRC大致如下:
     
     - (void)setData:(NSArray *)data
     {
         if (_data != data) {
             [_data release];
             _data = [data copy/retain];
         }
     }
     
     
     */
    
    {
        
        
        NSBookAG *ag = [[NSBookAG alloc] init];
        NSBookAG *ag1 = [ag copy];
        NSLog(@"ag = %p,ag1 = %p",ag,ag1);
        NSLog(@"ag = %d,ag1 = %d",[ag retainCount],[ag1 retainCount]);
        
        
        NSMutableArray *arry = [[NSMutableArray alloc] initWithObjects:@"key",@"obj",nil];
        NSMutableArray *arry1  = [arry copy];
        NSLog(@"arry1 = %p arrry = %p",arry1,arry);
        
        [arry release];
        [arry1 release];
        
        
        NSArray *arry2 = @[@"abc"];
        NSArray *arr3 = [arry2 copy];
        
        NSLog(@"arry2 = %p arr3 = %p",arry2,arr3);
        NSLog(@"arry2 = %d arr3 = %d",[arry2 retainCount],[arr3 retainCount]);
    }
    
}

- (void)deallocFuc
{
    /*
     
    在64bit中，引用计数可以直接存储在优化过的isa指针中，也可能存储在SideTable类中结构如下所示:
    struct SideTable {
        spinlock_t slock;
        RefcountMap refcnts; //存放着引用计数的散列表
        weak_table_t weak_table;
     
     
     weak_table是Runtime维护了一个hash(哈希)表，用于存储指向某个对象的所有weak指针。weak表其实是一个hash（哈希）表，Key是所指对象的地址，Value是weak指针的地址（这个地址的值是所指对象指针的地址）数组，weak对象在dealloc的时候会被清空
     
    */
    
    

}

- (void)autoreleaseFun
{
    
    
    @autoreleasepool {
        NSBookAG *ag = [[[NSBookAG alloc] init] autorelease];
    }
    
    /*
     
     //以上的代码转成C++代码大致如下:
     
     struct __AtAutoreleasePool {
     __AtAutoreleasePool() { // 构造函数，在创建结构体的时候调用
     atautoreleasepoolobj = objc_autoreleasePoolPush();
     }
     
     ~__AtAutoreleasePool() { // 析构函数，在结构体销毁的时候调用
     objc_autoreleasePoolPop(atautoreleasepoolobj);
     }
     
     void * atautoreleasepoolobj;
     };
     
     
     
     atautoreleasepoolobj = objc_autoreleasePoolPush();
     
     NSBookAG *ag = [[[NSBookAG alloc] init] autorelease];
     
     objc_autoreleasePoolPop(atautoreleasepoolobj);
     
     */
    
    
    
    
    
    /*
     自动释放池的主要底层数据结构是：__AtAutoreleasePool、AutoreleasePoolPage
     
     每个AutoreleasePoolPage对象占用4096字节内存，除了用来存放它内部的成员变量，剩下的空间用来存放autorelease对象的地址

     
     调用了autorelease的对象最终都是通过AutoreleasePoolPage对象来管理的,AutoreleasePoolPage的主要
     结构为:
     struct AutoreleasePoolPage {
         magic_t const magic;
         id *next;                //next指向每次要objc_autoreleasePoolPush的时候的地址
         pthread_t const thread;
         AutoreleasePoolPage * const parent;  //上一个page
         AutoreleasePoolPage *child;    //下一个page
         uint32_t const depth;
         uint32_t hiwat;
     }
     
     所有的AutoreleasePoolPage是通过双向循环链表结合起来的
     
     
     调用objc_autoreleasePoolPush方法会将一个POOL_BOUNDARY入栈，并且返回其存放的内存地址
     
     调用objc_autoreleasePoolPop方法时传入一个POOL_BOUNDARY的内存地址，会从最后一个入栈的对象开始发送release消息，直到遇到这个POOL_BOUNDARY

     
     
     iOS在主线程的Runloop中注册了2个Observer
     第1个Observer监听了kCFRunLoopEntry事件，会调用objc_autoreleasePoolPush()
     第2个Observer 监听了kCFRunLoopBeforeWaiting事件，会调用objc_autoreleasePoolPop()、objc_autoreleasePoolPush()
     监听了kCFRunLoopBeforeExit事件，会调用objc_autoreleasePoolPop()

     
     
     */
    
    NSLog(@"%@",[NSRunLoop mainRunLoop]);
    
    
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //timer定时器很容易导致循环引用，如果target = self,很容易导致timier持有target即self，self持有timer，导致内存泄露，用proxy可以解决 或者用weak解决
    //当runloop任务过重，NSTimer可能不准，GCD的Timer不依赖定时器，定时任务会更准
   // [self timerMemory];
    
    
    /*
     
     iOS内存布局如下,从低地址到高地址如下:
     代码段
     数据段: 字符串常量，全局变量，静态变量，包括初始化和卫初始化
     堆：函数调用开销，比如局部变量。分配的内存空间地址越来越小
     栈：通过alloc、malloc、calloc等动态分配的空间，分配的内存空间地址越来越大
     内核区
     */
    
    [self tagpointer];
    
    [self retainFun];
    
    [self deallocFuc];
    
    [self autoreleaseFun];
    
}


















- (void)dealloc
{
    
    [self.timer invalidate];
    NSLog(@"%s",__func__);
}



@end
