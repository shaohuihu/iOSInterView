//
//  RunLoopController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/8.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "RunLoopController.h"

@interface RunLoopController ()
{
    NSTimer *timer;
}


@end

@implementation RunLoopController



- (void)timerRunInRunLoop
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run2) userInfo:nil repeats:YES];
    [runLoop addTimer:timer2 forMode:UITrackingRunLoopMode];
    
    NSTimer *timer3 = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run3) userInfo:nil repeats:YES];
    [runLoop addTimer:timer3 forMode:NSRunLoopCommonModes];
    NSLog(@"*********\n%@",runLoop);
}


- (void)run
{
    NSLog(@"---DefaultRunLoopMode");
}

- (void)run2
{
    NSLog(@"---UITrackingRunLoopMode");
}

- (void)run3
{
    NSLog(@"---NSRunLoopCommonModes");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //关于runloop的5个类
    //CFRunLoopRef
    //CFRunLoopModeRef
    //CFRunLoopSourceRef
    //CFRunLoopTimerRef
    //CFRunLoopObserverRef
    
    typedef struct __CFRunLoopMode *CFRunLoopModeRef;
    typedef struct __CFRunLoop *CFRunLoopRef;
    
    
    struct __CFRunLoop {
        pthread_t _pthread; //每个runloop都有唯一的一个与之对应的线程
        CFMutableSetRef _commonModes; //存储的被标记为common modes的模式 一般就是UITrackingRunLoopMode 和 kCFRunLoopDefaultMode 集合
        CFMutableSetRef _commonModeItems; //运行在common模式下的若干个/sources/timers/observers/
        CFRunLoopModeRef _currentMode; //当前运行的mode
        CFMutableSetRef _modes; //各个modes里面存的是各个运行模式下面，执行的sources，observers，timers 这里监控到的有以下mode:
        
           // UITrackingRunLoopMode 跟踪用户交互事件（用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他Mode影响）
           // GSEventReceiveRunLoopMode  接受系统内部事件，通常用不到
           // kCFRunLoopDefaultMode App的默认运行模式，通常主线程是在这个运行模式下运行
           // UIInitializati  在刚启动App时第进入的第一个Mode，启动完成后就不再使用
           // kCFRunLoopCommonModes 是一种伪模式，指可以在标记为Common Modes的模式下运行
        
           //RunLoop只会运行在一种模式，如果需要切换模式，需要退出当前runloop，重新进入新的RunLoop
        
    };
    
    
    struct __CFRunLoopMode {
        CFStringRef _name;
        CFMutableSetRef _sources0;
        CFMutableSetRef _sources1;
        CFMutableArrayRef _observers;
        CFMutableArrayRef _timers;
        
    };
    
    
    [self createObserver];
    
    //[self timerRunInRunLoop];
    
    
    [self timer];
    
    //source0 触摸事件处理
    //source1 基于port线程间通信，系统事件捕捉
    //Timers NSTimer performSelector:withObject:afterDelay:
    //Observers 用于监听runloop状态 UI刷新(BeforeWaiting) Autorelease pool（BeforeWaiting）
    
    
    // runloop 休眠的原理是调用内核函数mach_msg
    
    // runloop 应用:
    // 控制线程生命周期（线程保活):开启一个线程后，获取到runloop 添加一个source 或者timer，并在某种模式下运行起来，如果需要销毁线程，则停止就可以。
    
    // 解决NSTimer在滑动时停止工作的问题
    // 监控应用卡顿
    // 性能优化
    
    
    
   
    
  


    

    
    
    
    
}

- (void)createObserver
{
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
    // 添加Observer到RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    // 释放
    CFRelease(observer);
}


void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"kCFRunLoopBeforeTimers");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"kCFRunLoopBeforeWaiting");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
}

- (void)timer
{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [scroll setBackgroundColor:[UIColor redColor]];
    scroll.contentSize = CGSizeMake(1000, 1000);
    scroll.scrollEnabled = YES;
    
    [self.view addSubview:scroll];
    
    
    // 这里容易导致循环引用
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

- (void)count
{
    
    static int count = 0;
    NSLog(@"%d", ++count);
    
    if(count > 10){
        [timer invalidate];
        timer = nil;
        count = 0;
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}


@end
