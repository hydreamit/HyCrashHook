//
//  HyCrashHookMethods.c
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//

#include "HyCrashHookMethods.h"


void hy_swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector) {
    
    if (!cls) { return;}
    
    Method originalMethod = class_getClassMethod(cls, originSelector);
    Method swizzledMethod = class_getClassMethod(cls, swizzleSelector);
    
    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* swizzing super class method, added if not exist */
        class_replaceMethod(metacls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(metacls,
                            swizzleSelector,
                            class_replaceMethod(metacls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}


void hy_swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector) {
    
    if (!cls) { return;}
    
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    
    /* add selector if not exist, implement append with method */
    if (class_addMethod(cls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* replace class instance method, added if selector not exist */
        /* for class cluster , it always add new selector here */
        class_replaceMethod(cls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(cls,
                            swizzleSelector,
                            class_replaceMethod(cls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}


void hy_swizzleClassMethodToBlock(Class cls, SEL originSelector, SwizzleMethodToBlock block) {
    
    __block IMP originalIMP = NULL;
    SWizzleImpProvider originalImpProvider = ^IMP {
        IMP imp = originalIMP;
        if (NULL == imp){
            Class superclass = class_getSuperclass(cls);
            imp = method_getImplementation(class_getInstanceMethod(superclass,originSelector));
        }
        return imp;
    };
    
    originalIMP = class_replaceMethod(objc_getMetaClass(NSStringFromClass(cls).UTF8String),
                                      originSelector,
                                      imp_implementationWithBlock(block(originSelector, originalImpProvider)),
                                      method_getTypeEncoding(class_getClassMethod(cls, originSelector)));
}


void hy_swizzleInstanceMethodToBlock(Class cls, SEL originSelector, SwizzleMethodToBlock block) {
    
    __block IMP originalIMP = NULL;
    SWizzleImpProvider originalImpProvider = ^IMP {
        IMP imp = originalIMP;
        if (NULL == imp){
            Class superclass = class_getSuperclass(cls);
            imp = method_getImplementation(class_getInstanceMethod(superclass,originSelector));
        }
        return imp;
    };
    
    originalIMP = class_replaceMethod(cls,
                                      originSelector,
                                      imp_implementationWithBlock(block(originSelector, originalImpProvider)),
                                      method_getTypeEncoding(class_getInstanceMethod(cls, originSelector)));
}


void hy_swizzleClassMethods(id cls, NSArray<NSString *> *methods) {
    
    if ([cls isKindOfClass:NSArray.class] || [cls isKindOfClass:NSMutableArray.class]) {
        [((NSArray *)cls) enumerateObjectsUsingBlock:^(NSString *  _Nonnull classString, NSUInteger idx, BOOL * _Nonnull stop) {
            [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                hy_swizzleClassMethod(NSClassFromString(classString),
                                      NSSelectorFromString(obj),
                                      NSSelectorFromString([NSString stringWithFormat:@"hy_%@",obj]));
            }];
        }];
    } else {
        [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            hy_swizzleClassMethod(cls,
                                  NSSelectorFromString(obj),
                                  NSSelectorFromString([NSString stringWithFormat:@"hy_%@",obj]));
        }];
    }
}


void hy_swizzleInstanceMethods(id cls, NSArray<NSString *> *methods) {
    
    if ([cls isKindOfClass:NSArray.class] || [cls isKindOfClass:NSMutableArray.class]) {
        [((NSArray *)cls) enumerateObjectsUsingBlock:^(NSString *  _Nonnull classString, NSUInteger idx, BOOL * _Nonnull stop) {
            [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                hy_swizzleInstanceMethod(NSClassFromString(classString),
                                         NSSelectorFromString(obj),
                                         NSSelectorFromString([NSString stringWithFormat:@"hy_%@",obj]));
            }];
        }];
    } else {
        [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            hy_swizzleInstanceMethod(cls,
                                     NSSelectorFromString(obj),
                                     NSSelectorFromString([NSString stringWithFormat:@"hy_%@",obj]));
        }];
    }
}


#define HySwizzleDeallocKey @"HySwizzleDealloc"
static NSMutableSet *swizzledDeallocClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledDeallocClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledDeallocClasses = [[NSMutableSet alloc] init];
    });
    return swizzledDeallocClasses;
}

void hy_swizzleDealloc(id instance, SwizzleDeallocBlock performBlock) {
    
    @synchronized (swizzledDeallocClasses()) {
        
        Class cls = [instance class];
        
        NSString *className = NSStringFromClass(cls);
        
        if (![swizzledDeallocClasses() containsObject:className]) {
            
            SEL deallocSelector = sel_registerName("dealloc");
            
            __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
            
            id newDealloc = ^(__unsafe_unretained id self) {
                
                NSMutableArray *array = objc_getAssociatedObject(self, HySwizzleDeallocKey);
                for (SwizzleDeallocBlock obj in array) {
                    obj(self);
                }
                [array removeAllObjects];
                
                if (originalDealloc == NULL) {
                    struct objc_super superInfo = {
                        .receiver = self,
                        .super_class = class_getSuperclass(cls)
                    };
                    void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                    msgSend(&superInfo, deallocSelector);
                } else {
                    originalDealloc(self, deallocSelector);
                }
            };
            
            IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
            
            if (!class_addMethod(cls, deallocSelector, newDeallocIMP, "v@:")) {
                // The class already contains a method implementation.
                Method deallocMethod = class_getInstanceMethod(cls, deallocSelector);
                
                // We need to store original implementation before setting new implementation
                // in case method is called at the time of setting.
                originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
                
                // We need to store original implementation again, in case it just changed.
                originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
            }
            
            NSMutableArray *array = @[].mutableCopy;
            if (performBlock) {
                [array addObject:performBlock];
            }
            objc_setAssociatedObject(instance, HySwizzleDeallocKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [swizzledDeallocClasses() addObject:className];
            
        } else {

            NSMutableArray *array = objc_getAssociatedObject(instance, HySwizzleDeallocKey);
            if (!array) {
                array = @[].mutableCopy;
                objc_setAssociatedObject(instance, HySwizzleDeallocKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            if (performBlock) {
               [array addObject:performBlock];
            }
        }
    }
}


NSArray *hy_getIvarList(Class cls) {
    
    NSMutableArray *ivarList = @[].mutableCopy;
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(cls, &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        [ivarList addObject:key];
    }
    free(ivars);
    return ivarList;
}

NSArray *hy_getPropertyList(Class cls) {
    
    NSMutableArray *propertyList = @[].mutableCopy;
    unsigned int count = 0;
    objc_property_t *propertys = class_copyPropertyList(cls, &count);
    for (int i = 0; i<count; i++) {
        objc_property_t property = propertys[i];
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];
        [propertyList addObject:key];
    }
    free(propertys);
    return propertyList;
}

NSArray *hy_getMethodList(Class cls) {
    
    NSMutableArray *methodList = @[].mutableCopy;
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methods[i];
        NSString *name = NSStringFromSelector(method_getName(method));
        [methodList addObject:name];
    }
    free(methods);
    return methodList;
}


BOOL hy_checkIvar(Class cls , NSString *ivar) {
    
    if (!cls || !ivar) { return NO;}
    return class_getInstanceVariable(cls, [ivar cStringUsingEncoding:NSUTF8StringEncoding]) != NULL;
}

BOOL hy_checkProperty(Class cls , NSString *property) {
    
    if (!cls || !property) { return NO;}
    return class_getProperty(cls, [property cStringUsingEncoding:NSUTF8StringEncoding]) != NULL;
}

BOOL hy_checkInstanceMethod(Class cls , SEL selector) {
    
    if (!cls || !selector) { return NO;}
    return class_getInstanceMethod(cls, selector) != nil;
}

BOOL hy_checkClassMethod(Class cls , SEL selector) {
    
    if (!cls || !selector) { return NO;}
    return class_getClassMethod(cls, selector) != nil;
}

