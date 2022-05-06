//
//  KVCController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/4/9.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "KVCController.h"
#import "NSBookAB.h"
@interface KVCController ()


@property (nonatomic, strong) NSBookAB *book;

@end

@implementation KVCController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.book = [[NSBookAB alloc] init];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.book addObserver:self forKeyPath:@"page" options:options context:nil];
    
    //KVC赋值
    [self.book setValue:@(100) forKey:@"page"];//触发KVO
    
    
    // 新添加一个只读属性，因为属性不生成setKey方法，但是我们可以构造一个跟set方法一样的方法，然后用KVC将参数传递过去,用成员变量赋值
    // self.book.maxNumber = 100;  //只读属性无法赋值
    [self.book setValue:@(100) forKey:@"maxNumber"];//赋值成功
    
}


/*KVC 赋值顺序
 先查看对象是否有setKey:如果没有看是否有_setKey
 因为setKey属性的set方法，如果KVC设置可写属性，则优先调用
 如果setKey和_setKey 都没有，查看类方法accessInstanceVariablesDirectly的返回值,如果返回FALSE(默认TRUE),直接报错 setValue:forUndefinedKey，如果返回TRUE，则按照如下查找顺序赋值：
    _key、_isKey、key、isKey

 如果都没有查找到setValue:forUndefinedKey
 **/


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"KVO %@的%@ - %@ - %@", object, keyPath, change, context);
}






@end
