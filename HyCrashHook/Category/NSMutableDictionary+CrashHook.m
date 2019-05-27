//
//  NSMutableDictionary+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//


#import "NSMutableDictionary+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableDictionary (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSClassFromString(@"__NSDictionaryM"), @[@"setObject:forKey:",
                                                                           @"removeObjectForKey:",
                                                                           @"setObject:forKeyedSubscript:"]);
    });
}

- (void)hy_setObject:(id)object forKey:(id)key {
    
    if (object && key) {
        [self hy_setObject:object forKey:key];
    } else {
        hy_crashHookLog(NSMutableDictionary.class, _cmd, [NSString stringWithFormat:@"invalid object:%@ and key:%@",object,key]);
    }
}

- (void)hy_removeObjectForKey:(id)key {
    
    if (key) {
        [self hy_removeObjectForKey:key];
    } else {
        hy_crashHookLog(NSMutableDictionary.class, _cmd, @"nil key");
    }
}

- (void)hy_setObject:(id)object forKeyedSubscript:(id<NSCopying>)key {
    
    if (object && key ) {
        [self hy_setObject:object forKeyedSubscript:key];
    } else {
        hy_crashHookLog(NSMutableDictionary.class, _cmd, [NSString stringWithFormat:@"object:%@ and forKeyedSubscript:%@",object,key]);
    }
}

@end
