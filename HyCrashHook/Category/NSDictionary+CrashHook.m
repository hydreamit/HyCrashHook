//
//  NSDictionary+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSDictionary+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSDictionary (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethods(NSDictionary.class, @[@"dictionaryWithObject:forKey:",
                                                     @"dictionaryWithObjects:forKeys:count:"]);
    });
}

+ (instancetype)hy_dictionaryWithObject:(id)object forKey:(id)key {
    
    if (object && key) {
        return [self hy_dictionaryWithObject:object forKey:key];
    }
    hy_crashHookLog(NSDictionary.class, _cmd, [NSString stringWithFormat:@"invalid object:%@ and key:%@",object,key]);
    return nil;
}

+ (instancetype)hy_dictionaryWithObjects:(const id [])objects
                                 forKeys:(const id [])keys
                                   count:(NSUInteger)cnt {
    
    NSInteger index = 0;
    id ks[cnt];
    id objs[cnt];
    for (NSInteger i = 0; i < cnt ; ++i) {
        if (keys[i] && objects[i]) {
            ks[index] = keys[i];
            objs[index] = objects[i];
            ++index;
        } else {
           hy_crashHookLog(NSDictionary.class, _cmd, [NSString stringWithFormat:@"invalid keys:%@ and object:%@",keys[i],objects[i]]);
        }
    }
    return [self hy_dictionaryWithObjects:objs forKeys:ks count:index];
}

@end
