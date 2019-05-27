//
//  NSMutableSet+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/13.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableSet+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableSet (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSClassFromString(@"__NSSetM"),@[@"addObject:",
                                                                   @"removeObject:"]);
    });
}

- (void)hy_addObject:(id)object {
    
    if (object) {
        [self hy_addObject:object];
    } else {
       hy_crashHookLog(NSMutableSet.class, _cmd, @"nil object");
    }
}

- (void)hy_removeObject:(id)object {
    
    if (object) {
        [self hy_removeObject:object];
    } else {
        hy_crashHookLog(NSMutableSet.class, _cmd, @"nil object");
    }
}

@end
