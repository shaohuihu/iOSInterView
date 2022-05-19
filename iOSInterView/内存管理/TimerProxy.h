//
//  TimerProxy.h
//  iOSInterView
//
//  Created by hushaohui on 2022/5/14.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@property (weak, nonatomic) id target; //这里一定要weak，否则target 和 proxy相互引用
@end
