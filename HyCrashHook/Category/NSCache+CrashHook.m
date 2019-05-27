//
//  NSCache+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/16.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSCache+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@implementation NSCache (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods([self class], @[@"setObject:forKey:",
                                                  @"setObject:forKey:cost:"]);
    });
}

- (void)hy_setObject:(id)obj forKey:(id)key {
    
    if (obj && key) {
        [self hy_setObject:obj forKey:key];
    } else {
        hy_crashHookLog(NSCache.class, _cmd, @"key and value can`t be nil");
    }
}

- (void)hy_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    
    if (obj && key) {
        [self hy_setObject:obj forKey:key cost:g];
    } else {
        hy_crashHookLog(NSCache.class, _cmd, @"key and value can`t be nil");
    }
}

@end
