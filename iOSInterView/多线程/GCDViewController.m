//
//  GCDViewController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/12.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "GCDViewController.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>
#import <pthread.h>
@interface GCDViewController ()


@property (nonatomic,assign)pthread_rwlock_t lock;
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
   // dispatch_sync 里面的任务是必须要当前执行，而queue添加的任务是加到dispatch_get_main_queue 最后面，必须等前面的任务执行完才能执行，2 和 3其实就是相互等待，最终都无法执行，造成死锁,解决办法:dispatch_sync 改成 dispatch_async 或者换成其它的queue
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"1");
    dispatch_sync(queue, ^{
        NSLog(@"2"); //不会打印
    });
    NSLog(@"3");  //不会打印
    
    
    
    //也会造成死锁，原因跟上相同，只是这个不是在主线程上
    dispatch_queue_t queue1 = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue1, ^{
        NSLog(@"1");
        dispatch_sync(queue1, ^{
            NSLog(@"2"); //不会打印
        });
        NSLog(@"3");  //不会打印
    });

    
}

- (void)group
{
    
    
    //同步方案,  创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加异步任务
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务1-%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务2-%@", [NSThread currentThread]);
        }
    });
    
    // 等前面的任务执行完毕后，会自动执行这个任务
    //    dispatch_group_notify(group, queue, ^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            for (int i = 0; i < 5; i++) {
    //                NSLog(@"任务3-%@", [NSThread currentThread]);
    //            }
    //        });
    //    });
    
    //    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    //        for (int i = 0; i < 5; i++) {
    //            NSLog(@"任务3-%@", [NSThread currentThread]);
    //        }
    //    });
    
    
    // 这里也可以使用栅栏函数 dispatch_barrier_async,保证先异步执行前面两任务，再异步执行后面两个任务
    // 使用栅栏函数的时候，不能使用全局队列（global_queue），否则无法对异步任务进行分割
    
    // dispatch_barrier_async 和 dispatch_barrier_sync的区别:
   //  同步栅栏函数会等待栅栏函数内的任务执行完，再执行后面的主线程或者子线程任务。异步栅栏函数不会等待栅栏函数内任务执行完，就会执行后面主线程的任务。异步栅栏函数不会阻塞主线程。
    
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务3-%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务4-%@", [NSThread currentThread]);
        }
    });
}

- (void)lock
{
    
    // 多线程同步方案
    
    // OSSpinLock High-level lock
    
    //OSSpinLock叫做”自旋锁”，等待锁的线程会处于忙等（busy-wait）状态，一直占用着CPU资源,目前已经不再安全，可能会出现优先级反转问题,如果等待锁的线程优先级较高，它会一直占用着CPU资源，优先级低的线程就无法释放锁
    OSSpinLock lock = OS_SPINLOCK_INIT;
    OSSpinLockLock(&lock);
    NSLog(@"OSSpinLock");
    OSSpinLockUnlock(&lock);
    
    
    //os_unfair_lock Low-level lock 用于取代不安全的OSSpinLock ，从iOS10开始才支持,从底层调用看，等待os_unfair_lock锁的线程会处于休眠状态，并非忙等
//    os_unfair_lock unfair_lock = OS_UNFAIR_LOCK_INIT;
//    os_unfair_lock_lock(&unfair_lock);
//    NSLog(@"os_unfair_lock");
//    os_unfair_lock_unlock(&unfair_lock);
    
    
    //pthread_mutex_t 互斥锁，等待锁的线程会处于休眠状态
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    // 初始化锁
    pthread_mutex_init(&mutex, &attr);
    pthread_mutex_lock(&mutex);
    NSLog(@"pthread_mutex_t PTHREAD_MUTEX_INITIALIZER ");
    pthread_mutex_unlock(&mutex);
    // 销毁属性
    pthread_mutexattr_destroy(&attr);
    
    //pthread_mutex_t 递归锁，允许同一个线程对一把锁进行重复加锁
    pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutexattr_t attr1;
    pthread_mutexattr_init(&attr1);
    pthread_mutexattr_settype(&attr1, PTHREAD_MUTEX_RECURSIVE);
    // 初始化锁
    pthread_mutex_init(&mutex1, &attr1);
    pthread_mutex_lock(&mutex1);
    NSLog(@"pthread_mutex_t PTHREAD_MUTEX_RECURSIVE ");
    pthread_mutex_unlock(&mutex1);
    // 销毁属性
    pthread_mutexattr_destroy(&attr);
    
    
    //pthread_mutex_t 条件
    pthread_mutex_t mutex_cond;
    pthread_cond_t cond;
    // 初始化锁
    pthread_mutex_init(&mutex_cond, NULL);
    //等待条件，进入休眠状态，放开mutex锁,被唤醒后，会再次对mutex加锁
    pthread_cond_wait(&cond, &mutex_cond);
    //激活一个等待该条件的线程
    pthread_cond_signal(&cond);
    //激活所有等待该条件的线程
    pthread_cond_broadcast(&cond);
    pthread_mutex_destroy(&mutex_cond);
    pthread_cond_destroy(&cond);
    
    //NSLock是对mutex的封装，NSRecursiveLock是对mutex递归锁的封装  NSCondition是mutex和cond的封装
    // NSConditionLock是对NSCondition的进一步封装，可以设置具体的条件值

    

    //信号量 在处理各个多线程之间依赖关系非常高效，使用非常频繁
    int value = 1;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(value);
    
    //  // 如果信号量的值 > 0，就让信号量的值减1，然后继续往下执行代码
    // 如果信号量的值 <= 0，就会休眠等待，直到信号量的值变成>0，就让信号量的值减1，然后继续往下执行代码
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(semaphore); //让信号量的值加1
    
    
    //串行队列，也可以同步多线程，因为串行队列，只会开启一个线程，所有在这个串行队列的所有任务都是根据FIFO执行
    dispatch_queue_t ser_queue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(ser_queue, ^{
        NSLog(@"DISPATCH_QUEUE_SERIAL 1");
        sleep(3);
    });
    
    dispatch_async(ser_queue, ^{
        NSLog(@"DISPATCH_QUEUE_SERIAL 2");
    });
    
    
    // @synchronized是对mutex递归锁的封装
     // Allocates recursive mutex associated with 'obj' if needed.
    // Returns OBJC_SYNC_SUCCESS once lock is acquired.
    
    
    /*
     
    各种的锁的性能从高到低
    os_unfair_lock
    OSSpinLock
    dispatch_semaphore
    pthread_mutex
    dispatch_queue(DISPATCH_QUEUE_SERIAL)
    NSLock
    NSCondition
    pthread_mutex(recursive)
    NSRecursiveLock
    NSConditionLock
    @synchronized
     
     
     什么情况使用自旋锁比较划算？
     预计线程等待锁的时间很短
     加锁的代码（临界区）经常被调用，但竞争情况很少发生
     CPU资源不紧张
     多核处理器
     
     什么情况使用互斥锁比较划算？
     预计线程等待锁的时间较长
     单核处理器
     临界区有IO操作
     临界区代码复杂或者循环量大
     临界区竞争非常激烈
     
     atomic用于保证属性setter、getter的原子性操作，相当于在getter和setter内部加了线程同步的锁
     它并不能保证使用属性的过程是线程安全
     
     
     */
}



- (void)readAndWrite
{
    pthread_rwlock_init(&_lock, NULL);
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            [self read];
        });
        dispatch_async(queue, ^{
            [self write];
        });
    }
}


- (void)read {
    pthread_rwlock_rdlock(&_lock);
    
    sleep(3);
    NSLog(@"%s", __func__);
    
    pthread_rwlock_unlock(&_lock);
}

- (void)write
{
    pthread_rwlock_wrlock(&_lock);
    
    sleep(3);
    NSLog(@"%s", __func__);
    
    pthread_rwlock_unlock(&_lock);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   // [self GCD1];
    
   // [self deadlock];
    
    
    //[self group];

    
    [self lock];
    
    
    //读写锁，多读单写，经常用于文件等数据的读写操作
    [self readAndWrite];
    
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}


@end
