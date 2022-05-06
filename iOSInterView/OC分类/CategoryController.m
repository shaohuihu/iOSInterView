//
//  CategoryController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/4/10.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "CategoryController.h"

@interface CategoryController ()

@end

@implementation CategoryController


//分类底层的结构如下:

/*
struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods; // 对象方法
    struct method_list_t *classMethods; // 类方法
    struct protocol_list_t *protocols; // 协议
    struct property_list_t *instanceProperties; // 属性
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;
    
    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }
    
    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
};*/



/* Category中能不能添成员变量？为什么？
答：Category中不能添加成员变量。成员变量信息是放在只读的class_ro_t结构体中，类一旦生成，就不能动态的添加成员变量。Category本身的底层结构category_t中也只保存了方法、属性和协议等信息，并没有保存成员变量信息。综合来说是Category中不能添加成员变量。但是分类中可以添加属性，系统不会生成对应的成员变量以及set和get方法实现，只会生成set和get方法的声明。

2.Category中添加的方法为什么会覆盖原来类中的方法？解释原理？
分类的实现原理是将category中的方法，属性，协议数据放在category_t结构体中，然后将结构体内的方法、属性，协议数据拷贝到类对象的方法列表中。
runtime首先加载某个类的所有Category数据，然后把所有Category的方法、属性、协议数据，合并到一个大数组中（后面参与编译的Category数据会在数组的前面），最后将合并后的分类数据（方法、属性、协议），插入到原来数据的前面。所以调用方法时会优先到调用Category中的方法，当父类中有同样的方法就不会调用。
 */



/*
 由于分类底层结构的限制无法添加成员变量到类中，但是可以通过关联对象间接实现
 相关API为
 
 添加关联对象
 void objc_setAssociatedObject(id object, const void * key,
 id value, objc_AssociationPolicy policy)
 
 获得关联对象
 id objc_getAssociatedObject(id object, const void * key)
 
 移除所有的关联对象
 void objc_removeAssociatedObjects(id object)
 
 涉及到关联对象的核心对象如下:
 AssociationsManager
 AssociationsHashMap
 ObjectAssociationMap
 ObjcAssociation
 
 
 关联对象由一个全局的AssociationsManager统一管理,当调用objc_setAssocicatedObject的时候对当前object地址值按位取反  ~uintptr_t作为key 以ObjcAssociation对象的形式存在AssociationsHashMap 中，遍历HashaMap根据key查找是否已经设置过关联对象，如果没有设置，则添加，设置了则更新，而每一个ObjcAssociation对象则是存放的policy value值。
 
 
 
 

 
 */




/*
 +load方法会在runtime加载类、分类时调用
 每个类、分类的+load，在程序运行过程中只调用一次
 
 调用顺序
 先调用类的+load
 按照编译先后顺序调用（先编译，先调用）
 调用子类的+load之前会先调用父类的+load
 
 再调用分类的+load
 按照编译先后顺序调用（先编译，先调用）
 
 +load方法是根据方法地址直接调用，并不是经过objc_msgSend函数调用
 */


/*
 +initialize方法会在类第一次接收到消息时调用
 
 调用顺序
 先调用父类的+initialize，再调用子类的+initialize
 (先初始化父类，再初始化子类，每个类只会初始化1次)
 
 +initialize和+load的很大区别是，+initialize是通过objc_msgSend进行调用的，所以有以下特点
 如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）
 如果分类实现了+initialize，就覆盖类本身的+initialize调用


 */

- (void)viewDidLoad {
    [super viewDidLoad];

  
}


@end
