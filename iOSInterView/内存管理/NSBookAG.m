//
//  NSBookAG.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/14.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "NSBookAG.h"

@implementation NSBookAG


- (instancetype)copyWithZone:(NSZone *)zone
{
//    NSBookAG *ag = [NSBookAG allocWithZone:zone];
//    ag.page = self.page;
    return [self retain];
}
@end
