//
//  GCDViewController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/12.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end

@implementation GCDViewController




- (void)GCD1
{
    //多线程概念: 同步，异步，并行，串行
    
    // 同步: 在当前线程中执行任务，一定不具备开启新线程的能力
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@" dispatch_sync %@",[NSThread currentThread]); //没有开启新线程,主线程执行，dispatch_get_global_queue 没有效果
    });
    
    //异步：在新的线程中执行任务，具备开启新线程的能力，可以开启一条或者多条线程
    ////由于是异步并发，以上两个for循环会交替打印，并发执行，不会相互干扰
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@" dispatch_async %@",[NSThread currentThread]); //开启新线程,并且可以开启多条线程
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i = 0; i < 10000 ; i++) {
                //NSLog(@"i1 = %d current thread %@",i,[NSThread currentThread]);
            }
        });
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i = 0; i < 10000 ; i++) {
                 //NSLog(@"i2 = %d current thread %@",i,[NSThread currentThread]);
            }
        });
        
    });
    
    
    //这里创建的是一个串行队列,串行队列只会创建一条线程 i1 和 i2 会依次打印
    //从另一个方面看:当执行第一个dispatch_async的时候，会把要执行的这个任务添加到串行queue中，执行第二个dispatch_async的时候，会把第二个要执行的任务添加到queue中。由于是串行，然后最终按照先进先出的原理，取出任务依次执行。
    dispatch_queue_t queue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (int i = 0; i < 10000 ; i++) {
            NSLog(@"i1 = %d current thread %@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10000 ; i++) {
            NSLog(@"i2 = %d current thread %@",i,[NSThread currentThread]);
        }
    });
    
    
}

- (void)deadlock
{
    //产生死锁：使用sync函数往当前串行队列中添加任务，会卡住当前的串行队列（产生死锁）
    //dispatch_sync 里面的任务是必须要当前执行，而queue添加的任务是加到dispatch_get_main_queue 最后面，必须等前面的任务执行完才能执行，2 和 3其实就是相互等待，最终都无法执行，造成死锁,解决办法:dispatch_sync 改成 dispatch_async 或者换成其它的queue
    
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    NSLog(@"1");
//    dispatch_sync(queue, ^{
//        NSLog(@"2"); //不会打印
//    });
//    NSLog(@"3");  //不会打印
    
    
    
    //也会造成死锁，原因跟上相同，只是这个不是在主线程上
//    dispatch_queue_t queue1 = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(queue1, ^{
//        NSLog(@"1");
//        dispatch_sync(queue1, ^{
//            NSLog(@"2"); //不会打印
//        });
//        NSLog(@"3");  //不会打印
//    });

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   // [self GCD1];
    
    [self deadlock];
    
    
    
    
    
    
    
    
    
}


@end
