//
//  NSNotificationCenter+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/13.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSNotificationCenter+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "NSObject+CrashHook.h"
#import "HyCrashHookMethods.h"


@implementation NSNotificationCenter (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSNotificationCenter.class,
                                  @[@"addObserver:selector:name:object:",
                                    @"addObserverForName:object:queue:usingBlock:",
                                    @"removeObserver:"]);
    });
}

- (void)hy_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    
    if ([observer isKindOfClass:NSObject.class]) {
        // observer dealloc, remove observer
        hy_swizzleDealloc(observer, ^(id instance){
            [[NSNotificationCenter defaultCenter] removeObserver:instance];
        });
    }
    
    [self hy_addObserver:observer selector:aSelector name:aName object:anObject];
}

#define HyAddObserverUsingBlockKey @"HyAddObserverUsingBlock"
- (id <NSObject>)hy_addObserverForName:(nullable NSNotificationName)name
                                object:(nullable id)obj
                                 queue:(nullable NSOperationQueue *)queue
                            usingBlock:(void (^)(NSNotification *note))block {
    
    // if block has 'self' retain cycle
    id observe = [self hy_addObserverForName:name
                                      object:obj
                                       queue:queue
                                  usingBlock:block];
    
    NSMutableSet *set = objc_getAssociatedObject(self, HyAddObserverUsingBlockKey);
    if (!set) {
        set = [NSMutableSet set];
        objc_setAssociatedObject(self, HyAddObserverUsingBlockKey, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [set addObject:observe];
    return observe;
}

- (void)hy_removeObserver:(id)observer {
 
    NSMutableSet *set = objc_getAssociatedObject(self, HyAddObserverUsingBlockKey);
    if (set && [set containsObject:observer]) {
        /*
             nc,
             queue,
             name,
             object,
             block
         */
        
        // solve retain cycle
        [observer setValue:nil forKeyPath:@"block"];
        
//        void (^noteBlock)(NSNotification *note) = [observer valueForKeyPath:@"block"];
//        NSLog(@"%@", noteBlock);
    }
    
    [self hy_removeObserver:observer];
}

@end
