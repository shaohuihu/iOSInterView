//
//  NSBookAD.h
//  iOSInterView
//
//  Created by hushaohui on 2022/5/1.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


typedef void(^Block)(int number);
@interface NSBookAD : NSObject

@property (nonatomic,assign)NSInteger page;

@property (nonatomic,copy) Block block;


@end
