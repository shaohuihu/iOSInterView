//
//  SafeController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/29.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "SafeController.h"

@interface SafeController ()

@end

@implementation SafeController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    /*
     
     1 字符串加密：针对oc/c/c++的字符串，可以用clang 遍历语法树，获取到c和oc字符串，然后对字符串进行AES加密，调用加密和解密的函数可以做成inline函数
     
     2 反调试:ptrace sysctl syscall 。如果要反反调试:fishhook相关函数
     
     3 反动态库注入: -Wl,-sectcreate,__RESTRICT,__restrict,/dev/null。如果要反反注入:修改__restrict
     
     4 代码混淆:利用 llvm 编写 pass
     
     */
    
}


@end
