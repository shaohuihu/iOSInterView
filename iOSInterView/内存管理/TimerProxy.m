//
//  TimerProxy.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/14.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "TimerProxy.h"

@implementation TimerProxy


+ (instancetype)proxyWithTarget:(id)target
{
    // NSProxy对象不需要调用init，因为它本来就没有init方法
    TimerProxy *proxy = [TimerProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if(!self.target) return [super methodSignatureForSelector:sel];
    
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    
    if(!self.target) return [super forwardInvocation:invocation];
    
    [invocation invokeWithTarget:self.target];
}


- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
