//
//  CADisplayLink+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/23.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "CADisplayLink+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@interface HyDisplayLinkProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic,weak) id target;
@property (nonatomic,weak) CADisplayLink *link;
@end
@implementation HyDisplayLinkProxy

+ (instancetype)proxyWithTarget:(id)target {
    HyDisplayLinkProxy *proxy = [HyDisplayLinkProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    
    if (self.target) {
        return [self.target methodSignatureForSelector:sel];
    } else {
        
        hy_crashHookLog(CADisplayLink.class, NSSelectorFromString(@"displayLinkWithTarget:selector:"), @"not invalidate");
        [self.link invalidate];
        self.link = nil;
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    
    if (self.target) {
        [invocation invokeWithTarget:self.target];
    }
}
@end



@implementation CADisplayLink (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethods(CADisplayLink.class, @[@"displayLinkWithTarget:selector:"]);
    });
}

+ (CADisplayLink *)hy_displayLinkWithTarget:(id)target selector:(SEL)sel {
    
    HyDisplayLinkProxy *newTarget = [HyDisplayLinkProxy proxyWithTarget:target];
    CADisplayLink *link = [self hy_displayLinkWithTarget:newTarget selector:sel];
    newTarget.link = link;
    return link;
}

@end
