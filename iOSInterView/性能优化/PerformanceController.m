//
//  PerformanceController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/5/15.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "PerformanceController.h"

@interface PerformanceController ()

@end

@implementation PerformanceController

- (void)UI
{
    /*
     在屏幕成像过程中，CPU和GPU起着比较重要的作用
     
     CPU（Central Processing Unit，中央处理器）主要负责对象的创建和销毁、对象属性的调整、布局计算、文本的计算和排版、图片的格式转换和解码、图像的绘制（Core Graphics）
     
     GPU（Graphics Processing Unit，图形处理器）主要负责纹理的渲染
     
     卡顿的产生： 每次垂直同步信号VSync 会把CPU计算好和GPU渲染好的数据显示到屏幕上，如果CPU和GPU在垂直同步信号来的时候，还没有完全处理好要显示的帧，这时会将上一帧显示出来，而当前这一帧就没显示出来(掉帧)，就造成了所谓的卡顿，这一帧会在下个垂直同步信号VSync的时候显示。
     
     按照60FPS的刷帧率，每隔16ms就会有一次VSync信号，也就是16m内完成CPU和GPU的计算和渲染就不会卡顿。优化主要是从CPU和GPU两方面去优化:
     
     CPU优化:
     
     尽量用轻量级的对象，比如用不到事件处理的地方，可以考虑使用CALayer取代UIView
     
     不要频繁地调用UIView的相关属性，比如frame、bounds、transform等属性，尽量减少不必要的修改
     
     尽量提前计算好布局，在有需要时一次性调整对应的属性，不要多次修改属性
     
     Autolayout会比直接设置frame消耗更多的CPU资源
     
     图片的size最好刚好跟UIImageView的size保持一致
     
     控制一下线程的最大并发数量
     
     尽量把耗时的操作放到子线程
     文本处理（尺寸计算、绘制）
     图片处理（解码、绘制）
     
     
     GPU优化:
     
     尽量避免短时间内大量图片的显示，尽可能将多张图片合成一张进行显示
     
     GPU能处理的最大纹理尺寸是4096x4096，一旦超过这个尺寸，就会占用CPU资源进行处理，所以纹理尽量不要超过这个尺寸
     
     尽量减少视图数量和层次
     
     减少透明的视图（alpha<1），不透明的就设置opaque为YES
     
     尽量避免出现离屏渲染
     
     
     在OpenGL中，GPU有2种渲染方式
     On-Screen Rendering：当前屏幕渲染，在当前用于显示的屏幕缓冲区进行渲染操作
     Off-Screen Rendering：离屏渲染，在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作
     
     离屏渲染消耗性能的原因
     需要创建新的缓冲区
     离屏渲染的整个过程，需要多次切换上下文环境，先是从当前屏幕（On-Screen）切换到离屏（Off-Screen）；等到离屏渲染结束以后，将离屏缓冲区的渲染结果显示到屏幕上，又需要将上下文环境从离屏切换到当前屏幕
     
     哪些操作会触发离屏渲染？
     光栅化，layer.shouldRasterize = YES
     
     遮罩，layer.mask
     
     圆角，同时设置layer.masksToBounds = YES、layer.cornerRadius大于0
     考虑通过CoreGraphics绘制裁剪圆角，或者叫美工提供圆角图片
     
     阴影，layer.shadowXXX
     如果设置了layer.shadowPath就不会产生离屏渲染
     
     卡顿检测:
     可以通过runloop 监控查看当前状Activities 比如kCFRunLoopBeforeSources和 kCFRunLoopAfterWaiting这两个状态的切换时间
     
     
     */
}

- (void)Power
{
    /*
     
     尽可能降低CPU、GPU功耗
     
     少用定时器
     
     优化I/O操作
     尽量不要频繁写入小数据，最好批量一次性写入
     读写大量重要数据时，考虑用dispatch_io，其提供了基于GCD的异步操作文件I/O的API。用dispatch_io系统会优化磁盘访问
     数据量比较大的，建议使用数据库（比如SQLite、CoreData）
     
     网络优化
     减少、压缩网络数据
     如果多次请求的结果是相同的，尽量使用缓存
     使用断点续传，否则网络不稳定时可能多次传输相同的内容
     网络不可用时，不要尝试执行网络请求
     让用户可以取消长时间运行或者速度很慢的网络操作，设置合适的超时时间
     批量传输，比如，下载视频流时，不要传输很小的数据包，直接下载整个文件或者一大块一大块地下载。如果下载广告，一次性多下载一些，然后再慢慢展示。如果下载电子邮件，一次下载多封，不要一封一封地下载
     
     
     定位优化
     如果只是需要快速确定用户位置，最好用CLLocationManager的requestLocation方法。定位完成后，会自动让定位硬件断电
     如果不是导航应用，尽量不要实时更新位置，定位完毕就关掉定位服务
     尽量降低定位精度，比如尽量不要使用精度最高的kCLLocationAccuracyBest
     需要后台定位时，尽量设置pausesLocationUpdatesAutomatically为YES，如果用户不太可能移动的时候系统会自动暂停位置更新
     尽量不要使用startMonitoringSignificantLocationChanges，优先考虑startMonitoringForRegion:
     
     硬件检测优化
     用户移动、摇晃、倾斜设备时，会产生动作(motion)事件，这些事件由加速度计、陀螺仪、磁力计等硬件检测。在不需要检测的场合，应该及时关闭这些硬件


     */
}

- (void)dyld
{
   /*
    
    Dyld是动态库链接器。在程序启动过程中负责加载所有库和可执行文件。
    在此过程中完成对这些库和可执行文件的符号重定向(Rebase)和符号绑定(Binding)等操作
    
    iOS APP的启动流程可以通过在xcode的Edit Scheme ->Run->Arguments -> Environment Variables
    中加入环境变量DYLD_PRINT_STATISTICS打印出来
    
    Total pre-main time: 953.02 milliseconds (100.0%)
    dylib loading time: 227.25 milliseconds (23.8%)
    rebase/binding time: 573.50 milliseconds (60.1%)
    ObjC setup time:  51.72 milliseconds (5.4%)
    initializer time: 100.27 milliseconds (10.5%)
    slowest intializers :
    libSystem.dylib :   5.32 milliseconds (0.5%)
    libMainThreadChecker.dylib :  45.09 milliseconds (4.7%)
    AFNetworking :  33.52 milliseconds (3.5%)
    
    
    
    
    dylib loading 阶段是动态链接库dylib加载动态库的阶段，包括系统动态库和我们自己的动态库。
    rebase/binding这个阶段实际就是两个操作rebase和binding。rebase就是内部符号偏移修正，binding是外部符号绑定。
    ObjC setup这一阶段主要是OC类相关的事务，比如类的注册，category、protocol的读取等等。
    intializers 程序的初始化，包括所依赖的动态库的初始化。在这期间会调用 Objc 类的 + load 函数，调用 C++ 中带有constructor 标记的函数等。
    
    将 DYLD_PRINT_STATISTICS换成DYLD_PRINT_STATISTICS_DETAILS 看到更详细的打印
    
    
    total time: 1.6 seconds (100.0%)
    total images loaded:  220 (0 from dyld shared cache)
    total segments mapped: 652, into 93367 pages with 6053 pages pre-fetched
    total images loading time: 1.1 seconds (70.5%)
    total load time in ObjC: 144.31 milliseconds (9.0%)
    total debugger pause time: 1.0 seconds (63.8%)
    total dtrace DOF registration time:   0.46 milliseconds (0.0%)
    total rebase fixups:  2,128,372
    total rebase fixups time: 105.63 milliseconds (6.5%)
    total binding fixups: 246,449
    total binding fixups time:  81.44 milliseconds (5.0%)
    total weak binding fixups time:   0.70 milliseconds (0.0%)
    total redo shared cached bindings time:  80.92 milliseconds (5.0%)
    total bindings lazily fixed up: 0 of 0
    total time in initializers and ObjC +load: 138.80 milliseconds (8.6%)
    libSystem.dylib :   5.75 milliseconds (0.3%)
    libBacktraceRecording.dylib :   4.46 milliseconds (0.2%)
    CoreFoundation :   7.58 milliseconds (0.4%)
    Foundation :   3.41 milliseconds (0.2%)
    libMainThreadChecker.dylib :  66.25 milliseconds (4.1%)
    AFNetworking :  37.19 milliseconds (2.3%)
    iOSInterView :   7.50 milliseconds (0.4%)
    total symbol trie searches:    126622
    total symbol table binary searches:    0
    total images defining weak symbols:  25
    total images using weak symbols:  63
    
    
    
    
    实际上也是上面四个阶段的扩展。比如说dyld loading包含了images loaded（共享缓存）和images loading等
    从load调用栈来看程序最开始启动是:
    _dyld_start:
    
    mov     x28, sp
    and     sp, x28, #~15        // force 16-byte alignment of stack
    mov    x0, #0
    mov    x1, #0
    stp    x1, x0, [sp, #-16]!    // make aligned terminating frame
    mov    fp, sp            // set up fp to point to terminating frame
    sub    sp, sp, #16             // make room for local variables
    #if __LP64__
    ldr     x0, [x28]               // get app's mh into x0
    ldr     x1, [x28, #8]           // get argc into x1 (kernel passes 32-bit int argc as 64-bits on stack to keep alignment)
    add     x2, x28, #16            // get argv into x2
    #else
    ldr     w0, [x28]               // get app's mh into x0
    ldr     w1, [x28, #4]           // get argc into x1 (kernel passes 32-bit int argc as 64-bits on stack to keep alignment)
    add     w2, w28, #8             // get argv into x2
    #endif
    adrp    x3,___dso_handle@page
    add     x3,x3,___dso_handle@pageoff // get dyld's mh in to x4
    mov    x4,sp                   // x5 has &startGlue
    
    // call dyldbootstrap::start(app_mh, argc, argv, dyld_mh, &startGlue)
    bl    __ZN13dyldbootstrap5startEPKN5dyld311MachOLoadedEiPPKcS3_Pm
    
    主要是app启动的一些准备工作，然后会调用dyldbootstrap::start函数  start函数会调用
    
    rebaseDyld，这个方法的rebaseDyld是dyld完成自身重定位的方法。首先dyld本身也是一个动态库。对于普通动态库，符号重定位可以由dyld来加载链接来完成，但是dyld的重定位谁来做？只能是它自身完成。这就是为什么会有rebaseDyld的原因，它其实是在对自身进行重定位，只有完成了自身的重定位它才能使用全局变量和静态变量。
    
    // if kernel had to slide dyld, we need to fix up load sensitive locations
    // we have to do this before using any global variables
    
    rebaseDyld(dyldsMachHeader);
    
    
    然后最终调用: dyld::_main((macho_header*)appsMachHeader, appsSlide, argc, argv, envp, apple, startGlue);
    App的启动也是在这个过程中完成的，调用流程大致如下:
    
    sMainExecutableMachHeader = mainExecutableMH; //主程序头部信息
    sMainExecutableSlide = mainExecutableSlide;   //设置随机偏移
    
    
    
    //加载共享缓存库
    load shared cache
    checkSharedRegionDisable((dyld3::MachOLoaded*)mainExecutableMH, mainExecutableSlide);
    mapSharedCache(mainExecutableSlide);
    
    
    //实例化主程序
    
    // instantiate ImageLoader for main executable
    sMainExecutable = instantiateFromLoadedImage(mainExecutableMH, mainExecutableSlide, sExecPath);
    gLinkContext.mainExecutable = sMainExecutable;
    gLinkContext.mainExecutableCodeSigned = hasCodeSignatureLoadCommand(mainExecutableMH);
    
    初始化一个ImageLoader类型的主程序sMainExecutable。后面的主程序相关的操作包括初始化都是通过这个对象来完成的。mainExecutableMH是mach-o文件头部信息，mainExecutableSlide主程序随机偏移值，sExecPath程序的路径。初始化之后检查应用签名
    
    
    //加载插入的动态库
    // load any inserted libraries
    if    ( sEnv.DYLD_INSERT_LIBRARIES != NULL ) {
            for (const char* const* lib = sEnv.DYLD_INSERT_LIBRARIES; *lib != NULL; ++lib)
            loadInsertedDylib(*lib);
    }
    
    //接下来是链接主程序 主要是对动态库rebase和bind，此时符号地址才能确定
    
    
    //接下来是 initializeMainExecutable(); 主程序初始化初始是app启动很重要的一个过程，在主程序初始化的过程中会同时初始化其所依赖的动态库，这一过程完成了包括ObjC的初始化等工作。+load和C++构造函数也是在这一过程中完成的。
    
    
    // initializeMainExecutable()主程序在初始化时是先递归调用其所依赖的动态库完成初始化然后在完成自身初始化。在上面的函数流程中load_images函数是在libobjc.A.dylib动态库里面的，它是在程序初始化之前被注册到dyld里面，等到初始化的时候执行，完成libobjc的映射，非懒加载类就是在这一过程中被加载并调用+load方法的。主程序初始化后，dyld就通知各方主程序准备要调用main函数了，然后开始寻找主程序的main函数入口地址返回
    
    
    
    //整个启动过程涉及到的几个重要方法和和动态库如下:
    
    
    动态库：
    libSystem.B.dylib，系统基础动态库，其他动态库的初始化必须在他之后。其初始化函数是libSystem_initializer；
    libdispatch.dylib，GCD所在的库，其初始化函数是libdispatch_init；
    libobjc.dylib，OC代码库，其初始化函数是_objc_init 。
    几个重要的函数：
    _objc_init；
    _dyld_objc_notify_register；
    map_images；
    load_images；
    
    objc_init是libobjc.A.dylib的初始化函数,包括运行时初始化等等
    
    函数_dyld_objc_notify_register是负责向dyld注册相关的回调函数，这些函数会在合适的时机dyld会通知调用，这函数就是它的三个参数load_images、map_images和unmap_image。dyld会把这三个函数缓存起来，以方便在合适的时机调用它们。
    
    
    函数map_images主要完成动态库中的类的映射、初始化等操作。也就是我们前面打印的ObjC setUp阶段。map_images通过镜像文件的读取类相关的信息进行初始化，然后保存在类表中。
    在完成类的映射，并完成非懒加载类的加载之后就可以调用OC相关的动态库的初始化方法initializer了。initializer完成之后就会调用load_images函数。
    
    
    load_images函数是在OC相关动态库完成初始化之后调用的，在这期间，这里首先会加载非懒加载类的category，然后调用所有已经加载的class和category的+load方法
    
    
    参考链接: https://www.jianshu.com/p/48554edb8e28
    
    
    
    
    
    
  
    
    
    
    
    
    
    
    
    
    
   
    
    
    */
    
  
}

+ (void)load
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UI];
    
    [self Power];
    
    [self dyld];
    
    
    
   
}


@end
