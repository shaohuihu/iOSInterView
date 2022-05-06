//
//  NSKVONotifying_NSBookAA.m
//  iOSInterView
//
//  Created by hushaohui on 2022/4/9.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "NSKVONotifying_NSBookAA.h"

@implementation NSKVONotifying_NSBookAA



- (void)setPage:(int)page
{
    _NSSetIntValueAndNotify();
}

// 伪代码
void _NSSetIntValueAndNotify()
{
    [self willChangeValueForKey:@"page"];
    [super setAge:age];
    [self didChangeValueForKey:@"age"];
}

- (void)didChangeValueForKey:(NSString *)key
{
    // 通知监听器，某某属性值发生了改变
    [oberser observeValueForKeyPath:key ofObject:self change:nil context:nil];
}



//下面是动态创建的子类重写的方法
- (Class)class
{
    return [NSBookAA class];
}

- (void)dealloc
{

}

- (BOOL)_isKVOA
{
    return YES;
}

@end
