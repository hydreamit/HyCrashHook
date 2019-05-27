//
//  NSSet+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/13.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookLogger.h"
#import "NSSet+CrashHook.h"
#import "HyCrashHookMethods.h"


@implementation NSSet (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        hy_swizzleClassMethod(NSSet.class, @selector(setWithObject:), @selector(hy_setWithObject:));
        hy_swizzleInstanceMethods(NSClassFromString(@"__NSPlaceholderSet"), @[@"initWithObjects:count:"]);
    });
}

+ (instancetype)hy_setWithObject:(id)object {

    if (object){
        return [self hy_setWithObject:object];
    }
    hy_crashHookLog(NSSet.class, _cmd, @"nil object");
    return nil;
}

- (instancetype)hy_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    
    NSInteger newObjsIndex = 0;
    id  newObjects[cnt];
    for (int i = 0; i < cnt; i++) {
        if (objects[i] != nil) {
            newObjects[newObjsIndex++] = objects[i];
        } else {
            hy_crashHookLog(NSSet.class, _cmd, [NSString stringWithFormat:@"invalid index object:%tu total:%tu",i,cnt]);
        }
    }
    return [self hy_initWithObjects:newObjects count:newObjsIndex];
}

@end
