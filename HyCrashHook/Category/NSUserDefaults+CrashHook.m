//
//  NSUserDefaults+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSUserDefaults+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


id ud_handleCrashHookLog(SEL sel, id returnValue) {
    hy_crashHookLog(NSUserDefaults.class, sel, @"key can`t be nil");
    return returnValue;
}


@implementation NSUserDefaults (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSUserDefaults.class, @[@"objectForKey:",
                                                          @"stringForKey:",
                                                          @"arrayForKey:",
                                                          @"dataForKey:",
                                                          @"URLForKey:",
                                                          @"stringArrayForKey:",
                                                          @"floatForKey:",
                                                          @"doubleForKey:",
                                                          @"integerForKey:",
                                                          @"boolForKey:",
                                                          @"setObject:forKey:"]);
    });
}

- (id)hy_objectForKey:(NSString *)defaultName {
    return defaultName ? [self hy_objectForKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

- (NSString *)hy_stringForKey:(NSString *)defaultName {
    return defaultName ? [self hy_stringForKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

- (NSArray *)hy_arrayForKey:(NSString *)defaultName {
    return defaultName ? [self hy_arrayForKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

- (NSData *)hy_dataForKey:(NSString *)defaultName {
    return defaultName ? [self hy_dataForKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

- (NSURL *)hy_URLForKey:(NSString *)defaultName {
    return defaultName ? [self hy_URLForKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

- (NSArray<NSString *> *)hy_stringArrayForKey:(NSString *)defaultName {
    return defaultName ? [self hy_stringArrayForKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

- (float)hy_floatForKey:(NSString *)defaultName {
     return defaultName ? [self hy_floatForKey:defaultName] : [ud_handleCrashHookLog(_cmd, @0) floatValue];
}

- (double)hy_doubleForKey:(NSString *)defaultName {
    return defaultName ? [self hy_doubleForKey:defaultName] : [ud_handleCrashHookLog(_cmd, @0) doubleValue];
}

- (NSInteger)hy_integerForKey:(NSString *)defaultName {
    return defaultName ? [self hy_integerForKey:defaultName] : [ud_handleCrashHookLog(_cmd, @0) integerValue];
}

- (BOOL)hy_boolForKey:(NSString *)defaultName {
     return defaultName ? [self hy_boolForKey:defaultName] : [ud_handleCrashHookLog(_cmd, @0) boolValue];
}

- (void)hy_setObject:(id)value forKey:(NSString *)defaultName {
    defaultName ? [self hy_setObject:value forKey:defaultName] : ud_handleCrashHookLog(_cmd, nil);
}

@end
