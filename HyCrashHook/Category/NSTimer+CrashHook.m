//
//  NSTimer+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/23.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSTimer+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@interface HyTimerProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic,weak) id target;
@property (nonatomic,weak) NSTimer *timer;
@property (nonatomic,copy) NSString *selString;
@end
@implementation HyTimerProxy

+ (instancetype)proxyWithTarget:(id)target {
    HyTimerProxy *proxy = [HyTimerProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    
    if (self.target) {
        return [self.target methodSignatureForSelector:sel];
    } else {
        
        hy_crashHookLog(NSTimer.class, NSSelectorFromString(self.selString), @"not invalidate");
        
        [self.timer invalidate];
        self.timer = nil;
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    
    if (self.target) {
        [invocation invokeWithTarget:self.target];
    }
}
@end


@implementation NSTimer (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethods(NSTimer.class,
                               @[@"timerWithTimeInterval:target:selector:userInfo:repeats:",
                                 @"scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:"]);

    });
}

// if repeats,  need addTimer to runLoop
+ (NSTimer *)hy_timerWithTimeInterval:(NSTimeInterval)ti
                            target:(id)aTarget
                          selector:(SEL)aSelector
                          userInfo:(nullable id)userInfo
                           repeats:(BOOL)yesOrNo {
    
    id newTarget = aTarget;
    if (yesOrNo) {
        newTarget = [HyTimerProxy proxyWithTarget:aTarget];
    }
    NSTimer *timer = [self hy_timerWithTimeInterval:ti
                                             target:newTarget
                                           selector:aSelector
                                           userInfo:userInfo
                                            repeats:yesOrNo];
    if (yesOrNo) {
        ((HyTimerProxy *)newTarget).timer = timer;
        ((HyTimerProxy *)newTarget).selString = @"timerWithTimeInterval:target:selector:userInfo:repeats:";
    }
    return timer;
}

+ (NSTimer *)hy_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)yesOrNo {
    
    id newTarget = aTarget;
    if (yesOrNo) {
        newTarget = [HyTimerProxy proxyWithTarget:aTarget];
    }
    NSTimer *timer = [self hy_scheduledTimerWithTimeInterval:ti
                                                      target:newTarget
                                                    selector:aSelector
                                                    userInfo:userInfo
                                                     repeats:yesOrNo];
    if (yesOrNo) {
        ((HyTimerProxy *)newTarget).timer = timer;
        ((HyTimerProxy *)newTarget).selString = @"scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:";
    }
    return timer;
}

@end
