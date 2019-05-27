//
//  HyCrashHookMethods.h
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/message.h>


typedef void (^SwizzleDeallocBlock)(id instance);
typedef IMP (^SWizzleImpProvider)(void);
typedef id (^SwizzleMethodToBlock)(SEL originSelector, SWizzleImpProvider impBlock);

// ClassMethod
void hy_swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector);
void hy_swizzleClassMethodToBlock(Class cls, SEL originSelector, SwizzleMethodToBlock block);
void hy_swizzleClassMethods(id cls, NSArray<NSString *> *methods);

// InstanceMethod
void hy_swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector);
void hy_swizzleInstanceMethodToBlock(Class cls, SEL originSelector, SwizzleMethodToBlock block);
void hy_swizzleInstanceMethods(id cls, NSArray<NSString *> *methods);


// Hook Dealloc
// performBlock can not contain 'self', if use 'self', please use performBlock 'instance'
void hy_swizzleDealloc(id instance, SwizzleDeallocBlock performBlock);

NSArray *hy_getIvarList(Class cls);
NSArray *hy_getPropertyList(Class cls);
NSArray *hy_getMethodList(Class cls);

BOOL hy_checkIvar(Class cls , NSString *ivar);
BOOL hy_checkProperty(Class cls , NSString *property);
BOOL hy_checkInstanceMethod(Class cls , SEL selector);
BOOL hy_checkClassMethod(Class cls , SEL selector);

