//
//  NSObject+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookLogger.h"
#import "NSObject+CrashHook.h"
#import "HyCrashHookMethods.h"


#define HyKvoSwizzleDeallocKey @"HyKvoSwizzleDealloc"
#define HyKvoObserverMangerKey @"HyKvoObserverManger"
@interface HyKvoObserverItem : NSObject
@property (nonatomic,assign) id observer;
@property (nonatomic,copy) NSString *keyPath;
@property (nonatomic,assign) void *context;
@property (nonatomic,assign) NSKeyValueObservingOptions options;
@end
@implementation HyKvoObserverItem
+ (instancetype)itemWithObserver:(id)observer
                         keyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context {
    
    HyKvoObserverItem *item = [[self alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    item.options = options;
    item.context = context;
    return item;
}
@end

@interface HyKvoObserverManger : NSObject
@property (nonatomic,strong) NSMutableArray<HyKvoObserverItem *> *kvoItems;
@property (nonatomic,strong) dispatch_semaphore_t semaphore;
@end
@implementation HyKvoObserverManger

- (void)addItem:(HyKvoObserverItem *)item {
    
    if (item && ![self.kvoItems containsObject:item]) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        [self.kvoItems addObject:item];
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)removeItem:(HyKvoObserverItem *)item {
    
    if (item && [self.kvoItems containsObject:item]) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        [self.kvoItems removeObject:item];
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (NSArray *)getItemsWithObserver:(id)observer {
    
    if (observer) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSMutableArray *mArray = @[].mutableCopy;
        for (HyKvoObserverItem *item in self.kvoItems) {
            if (item.observer == observer) {
                [mArray addObject:item];
            }
        }
        dispatch_semaphore_signal(self.semaphore);
        return mArray.copy;
    }
    return nil;
}

- (BOOL)checkItemIsExist:(HyKvoObserverItem *)item {
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    BOOL exist = NO;
    if (!item) {
        dispatch_semaphore_signal(self.semaphore);
        return exist;
    }
    exist = [self.kvoItems containsObject:item];
    dispatch_semaphore_signal(self.semaphore);
    return exist;
}

- (HyKvoObserverItem *)filterItemWithItem:(HyKvoObserverItem *)item {
    
    if (item) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        HyKvoObserverItem *filterItem = nil;
        // reverse find
        for (HyKvoObserverItem *obj in [[self.kvoItems reverseObjectEnumerator] allObjects]) {
            if (obj.observer == item.observer &&
                obj.keyPath == item.keyPath) {
                if (item.context) {
                    if (obj.context == item.context) {
                        filterItem = obj;
                    }
                } else {
                    filterItem = obj;
                }
                if (filterItem) { break; }
            }
        }
        dispatch_semaphore_signal(self.semaphore);
        return filterItem;
    }
    return nil;
}

- (dispatch_semaphore_t)semaphore{
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
        return _semaphore;
    }
    return _semaphore;
}
- (NSMutableArray<HyKvoObserverItem *> *)kvoItems {
    if (!_kvoItems){
        _kvoItems  = [NSMutableArray array];
    }
    return _kvoItems;
}
@end







@implementation NSObject (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // KVC
        hy_swizzleInstanceMethods([self class],@[@"setValue:forUndefinedKey:",
                                                 @"valueForUndefinedKey:"]);
        
        
        // KVO
        hy_swizzleInstanceMethods([self class],@[@"addObserver:forKeyPath:options:context:",
                                                 @"removeObserver:forKeyPath:",
                                                 @"removeObserver:forKeyPath:context:",
                                                 @"observeValueForKeyPath:ofObject:change:context:"]);
        
        
        // UnrecognizedSelector
        NSArray<NSString *> *swizzleSignatureMethods = @[@"methodSignatureForSelector:",
                                                         @"forwardInvocation:"];
        hy_swizzleClassMethods([self class], swizzleSignatureMethods);
        hy_swizzleInstanceMethods([self class], swizzleSignatureMethods);
    });
}

- (void)hy_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context {
    
    if ([self ignoreKVOWithInstance:observer]) {
        [self hy_addObserver:observer
                  forKeyPath:keyPath
                     options:options
                     context:context];
        return;
    }
    
    if (!observer || !keyPath.length) {
        return;
    }
    
    HyKvoObserverItem *item =
    [HyKvoObserverItem itemWithObserver:observer
                                keyPath:keyPath
                                options:options
                                context:context];
    
    HyKvoObserverManger *manger = objc_getAssociatedObject(self, HyKvoObserverMangerKey);
    if (!manger) {
        manger  = [[HyKvoObserverManger alloc] init];
        objc_setAssociatedObject(self, HyKvoObserverMangerKey, manger, OBJC_ASSOCIATION_RETAIN);
    }
    
    if (![manger checkItemIsExist:item]) {
        [manger addItem:item];
        [self hy_addObserver:observer
                  forKeyPath:keyPath
                     options:options
                     context:context];
    }
    
    // swizzled self dealloc
    NSString *swizzledSelfDealloc = objc_getAssociatedObject(self, HyKvoSwizzleDeallocKey);
    if (!swizzledSelfDealloc) {
        hy_swizzleDealloc(self, ^(id instance){
            
            // delete all KVO
            HyKvoObserverManger *manger = objc_getAssociatedObject(instance, HyKvoObserverMangerKey);
            if (manger.kvoItems.count) {
                [manger.kvoItems enumerateObjectsUsingBlock:^(HyKvoObserverItem *obj, NSUInteger idx, BOOL *stop) {
                    [instance removeObserver:obj.observer
                                  forKeyPath:obj.keyPath
                                     context:obj.context];
                }];
            }
        });
        objc_setAssociatedObject(self, HyKvoSwizzleDeallocKey, @"", OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    // swizzled observer dealloc
    NSString *swizzledObserverDealloc = objc_getAssociatedObject(observer, HyKvoSwizzleDeallocKey);
    if (!swizzledObserverDealloc) {
        hy_swizzleDealloc(observer, ^(id instance) {
            
            // delete KVO with belong boserver
            HyKvoObserverManger *manger = objc_getAssociatedObject(self, HyKvoObserverMangerKey);
            NSArray<HyKvoObserverItem *> *filterItems = [manger getItemsWithObserver:instance];
            if (filterItems.count) {
                [filterItems enumerateObjectsUsingBlock:^(HyKvoObserverItem *obj, NSUInteger idx, BOOL *stop) {
                    [self removeObserver:obj.observer
                              forKeyPath:obj.keyPath
                                 context:obj.context];
                }];
            }
        });
        objc_setAssociatedObject(observer, HyKvoSwizzleDeallocKey, @"", OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)hy_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath {
    
    if ([self ignoreKVOWithInstance:observer]) {
        [self hy_removeObserver:observer
                     forKeyPath:keyPath];
        return;
    }
    
    if (!observer && !keyPath.length) {
        return;
    }
    
    HyKvoObserverItem *item =
    [HyKvoObserverItem itemWithObserver:observer
                                keyPath:keyPath
                                options:0
                                context:nil];
    
    HyKvoObserverManger *manger = objc_getAssociatedObject(self, HyKvoObserverMangerKey);
    if (manger) {
        HyKvoObserverItem *filterItem = [manger filterItemWithItem:item];
        if (filterItem) {
            [manger removeItem:filterItem];
            [self hy_removeObserver:observer forKeyPath:keyPath];
        } else {
            hy_crashHookLog(self.class, _cmd, @"isObjectClass because it is not registered as an observer.");
        }
    } else {
        @try {
            [self hy_removeObserver:observer forKeyPath:keyPath];
        } @catch (NSException *exception) {
            hy_crashHookLog(self.class, _cmd, [NSString stringWithFormat:@"isObjectClass %@", exception.reason]);
        } @finally {
            
        }
    }
}

- (void)hy_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  context:(void*)context {
    
    if ([self ignoreKVOWithInstance:observer]) {
        [self hy_removeObserver:observer
                     forKeyPath:keyPath
                        context:context];
        return;
    }
    
    if (!observer && !keyPath.length) { return; }
    
    HyKvoObserverItem *item =
    [HyKvoObserverItem itemWithObserver:observer
                                keyPath:keyPath
                                options:0
                                context:context];
    
    HyKvoObserverManger *manger = objc_getAssociatedObject(self, HyKvoObserverMangerKey);
    if (manger) {
        HyKvoObserverItem *filterItem = [manger filterItemWithItem:item];
        if (filterItem) {
            [manger removeItem:filterItem];
            [self hy_removeObserver:observer
                         forKeyPath:keyPath
                            context:context];
        } else {
            hy_crashHookLog(self.class, _cmd, @"isObjectClass because it is not registered as an observer.");
        }
    } else {
        @try {
            [self hy_removeObserver:observer
                         forKeyPath:keyPath
                            context:context];
        } @catch (NSException *exception) {
            hy_crashHookLog(self.class, _cmd, [NSString stringWithFormat:@"isObjectClass %@", exception.reason]);
        } @finally {
            
        }
    }
}

- (void)hy_observeValueForKeyPath:(NSString *)keyPath
                         ofObject:(id)object
                           change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                          context:(void *)context {
    @try {
        [self hy_observeValueForKeyPath:keyPath
                               ofObject:object
                                 change:change
                                context:context];
    } @catch (NSException *exception) {
        hy_crashHookLog(self.class, _cmd, [NSString stringWithFormat:@"isObjectClass %@", exception.reason]);
    } @finally {
        
    }
}

- (BOOL)ignoreKVOWithInstance:(id)object{
    
    if (!object) { return NO; }
    
    //ignore ReactiveCocoa
    if (object_getClass(object) == objc_getClass("RACKVOProxy")) {
        return YES;
    }
    
    //ignore AMAP
    NSString* className = NSStringFromClass(object_getClass(object));
    if ([className hasPrefix:@"AMap"]) {
        return YES;
    }
    
    return NO;
}

- (void)hy_setValue:(id)value forUndefinedKey:(NSString *)key {
    
    hy_crashHookLog(self.class, _cmd, [NSString stringWithFormat:@"isObjectClass key: %@", key]);
}

- (id)hy_valueForUndefinedKey:(NSString *)key {
    
    hy_crashHookLog(self.class, _cmd, [NSString stringWithFormat:@"isObjectClass key: %@", key]);
    return nil;
}

+ (NSMethodSignature *)hy_methodSignatureForSelector:(SEL)aSelector {
    
    return [self hy_methodSignatureForSelector:aSelector] ?:
           [self.class checkObjectSignatureAndCurrentClass:self.class];
}

- (NSMethodSignature *)hy_methodSignatureForSelector:(SEL)aSelector {
    
    return [self hy_methodSignatureForSelector:aSelector] ?:
           [self.class checkObjectSignatureAndCurrentClass:self.class];
}

+ (NSMethodSignature *)checkObjectSignatureAndCurrentClass:(Class)currentClass {
    
    IMP originIMP = class_getMethodImplementation([NSObject class], @selector(methodSignatureForSelector:));
    IMP currentClassIMP = class_getMethodImplementation(currentClass, @selector(methodSignatureForSelector:));
    
    // If current class override methodSignatureForSelector return nil
    if (originIMP != currentClassIMP) {
        return nil;
    }
    
    // Customer method signature
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)hy_forwardInvocation:(NSInvocation *)invocation {
    
    hy_crashHookLog(self.class, _cmd ,[NSString stringWithFormat:@"isObjectClass Unrecognized instance class:%@ sent to selector:%@",NSStringFromClass(self.class),NSStringFromSelector(invocation.selector)]);
}

+ (void)hy_forwardClassInvocation:(NSInvocation *)invocation {
    
    hy_crashHookLog(self, _cmd, [NSString stringWithFormat:@"isObjectClass Unrecognized class:%@ sent to selector:%@",NSStringFromClass(self.class),NSStringFromSelector(invocation.selector)]);
}

@end
