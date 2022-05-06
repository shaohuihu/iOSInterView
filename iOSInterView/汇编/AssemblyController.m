//
//  AssemblyController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/4.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "AssemblyController.h"
#import "NSBookAF.h"
@interface AssemblyController ()

@end

@implementation AssemblyController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        NSBookAF *af = [[NSBookAF alloc] init];
        [af read];
    }
}

//以上方法转成ARM64汇编如下:

/*
 相关指令介绍
 
 stp：p是pair,把一对寄存器写入到右边内存中
 
 str和stur: 都是把寄存器的值读取到右边[内存中],区别是,stur右边的立即数是负数,u代表立即数是负数 str右边的立即数是正数
 add:  add    x29, sp, #0x30 ; x29 = sp + 0x30
 bl: 带返回地址的跳转指令 将下一条的指令地址存到lr (x30)中，跳转到标记处开始执行代码
 
 adrp:  adrp 一般和add 两条指令一起看，adrp作用是找到内存的哪一页，每一页内存4k ，也就是0x1000个字节
 比如下指令:
 
 0x1000518e0 <+24>:  adrp   x10, 5
 0x1000518e4 <+28>:  add    x10, x10, #0x7b8          ; =0x7b8
 
 流程如下:
 先把当前pc程序寄存器(就是正在执行的哪一条指令) 后三位清零(为了确定是哪一页) 地址则为:0x100051000
 偏移5页0x5000 加上这个地址等于 x10 = 0x100056000 再add  x10 = 0x1000567b8 
 
 
 
 
 
 
 
 
 
 */

/*

 
 开辟栈空间 并将 x29(fp)和x30(lr)的的值存起来,fp是保存上一个函数的相信息,lr存放的是函数返回地址，因为当中可能要修改，也需要先保存
函数空间存放局部变量一般为sp 和 fp之间的空间

0x1000518c8 <+0>:   sub    sp, sp, #0x40             ; =0x40
0x1000518cc <+4>:   stp    x29, x30, [sp, #0x30]
0x1000518d0 <+8>:   add    x29, sp, #0x30            ; =0x30
 
 
 
 
 调用[super viewDidLoad]
0x1000518d4 <+12>:  add    x8, sp, #0x10             ; =0x10
0x1000518d8 <+16>:  adrp   x9, 5
0x1000518dc <+20>:  add    x9, x9, #0x4b8            ; =0x4b8
0x1000518e0 <+24>:  adrp   x10, 5
0x1000518e4 <+28>:  add    x10, x10, #0x7b8          ; =0x7b8
0x1000518e8 <+32>:  stur   x0, [x29, #-0x8]
0x1000518ec <+36>:  stur   x1, [x29, #-0x10]
0x1000518f0 <+40>:  ldur   x0, [x29, #-0x8]
0x1000518f4 <+44>:  str    x0, [sp, #0x10]
0x1000518f8 <+48>:  ldr    x10, [x10]
0x1000518fc <+52>:  str    x10, [sp, #0x18]
0x100051900 <+56>:  ldr    x1, [x9]
0x100051904 <+60>:  mov    x0, x8
0x100051908 <+64>:  bl     0x100051ff8               ; symbol stub for: objc_msgSendSuper2
 
 
 
 
 [NSBookAF alloc] init
0x10005190c <+68>:  adrp   x8, 5
0x100051910 <+72>:  add    x8, x8, #0x4c0            ; =0x4c0
0x100051914 <+76>:  adrp   x9, 5
0x100051918 <+80>:  add    x9, x9, #0x748            ; =0x748
0x10005191c <+84>:  ldr    x9, [x9]
0x100051920 <+88>:  ldr    x1, [x8]
0x100051924 <+92>:  mov    x0, x9
0x100051928 <+96>:  bl     0x100051fec               ; symbol stub for: objc_msgSend
0x10005192c <+100>: adrp   x8, 5
0x100051930 <+104>: add    x8, x8, #0x4c8            ; =0x4c8
0x100051934 <+108>: ldr    x1, [x8]
0x100051938 <+112>: bl     0x100051fec               ; symbol stub for: objc_msgSend
 
 
 //调用read方法
0x10005193c <+116>: adrp   x8, 5
0x100051940 <+120>: add    x8, x8, #0x4d8            ; =0x4d8
0x100051944 <+124>: str    x0, [sp, #0x8]
0x100051948 <+128>: ldr    x9, [sp, #0x8]
0x10005194c <+132>: ldr    x1, [x8]
0x100051950 <+136>: mov    x0, x9
0x100051954 <+140>: bl     0x100051fec               ; symbol stub for: objc_msgSend
 
 
 
 //释放对象相关，只是编译器调用的函数
 
0x100051958 <+144>: mov    x8, #0x0
0x10005195c <+148>: add    x9, sp, #0x8              ; =0x8
0x100051960 <+152>: mov    x0, x9
0x100051964 <+156>: mov    x1, x8
0x100051968 <+160>: bl     0x100052040               ; symbol stub for: objc_storeStrong
 
 
 
 //还原栈空间，以及fp和lr
0x10005196c <+164>: ldp    x29, x30, [sp, #0x30]
0x100051970 <+168>: add    sp, sp, #0x40             ; =0x40
0x100051974 <+172>: ret

*/

@end
