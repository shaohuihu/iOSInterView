//
//  NSBookAE.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/2.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "NSBookAE.h"

@implementation NSBookAE


- (void)NSBookAE_forward:(int)age
{
    NSLog(@"NSBookAE_forward %d",age);
}

- (void)read
{
    
//     struct obj = {
//       self,
//       [NSBookAE class]
//      };
//     objc_msgSendSuper2(obj, sel_registerName("read"));
    
    // 调用super的时候先生成一个obj的结构体，再传给objc_msgSendSuper2
    //  这里可以通过lldb调试出来obj 两个参数  一个是self 一个是 [NSBookAE class]
    
    [super read];
    
    
    
}
@end
