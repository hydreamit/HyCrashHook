//
//  NSDecimalNumber+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSDecimalNumber+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@implementation NSDecimalNumber (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSDecimalNumber.class, @[@"decimalNumberByAdding:",
                                                           @"decimalNumberBySubtracting:",
                                                           @"decimalNumberByMultiplyingBy:",
                                                           @"decimalNumberByDividingBy:"]);
    });
}

- (NSDecimalNumber *)hy_decimalNumberByAdding:(NSDecimalNumber *)decimalNumber {

    if ([self checkWithDecimalNumber:decimalNumber]) {
        return [self hy_decimalNumberByAdding:decimalNumber];
    }
    hy_crashHookLog(NSDecimalNumber.class, _cmd, @"notANumber");
    return nil;
}

- (NSDecimalNumber *)hy_decimalNumberBySubtracting:(NSDecimalNumber *)decimalNumber {

    if ([self checkWithDecimalNumber:decimalNumber]) {
        return [self hy_decimalNumberBySubtracting:decimalNumber];
    }
    hy_crashHookLog(NSDecimalNumber.class, _cmd, @"notANumber");
    return nil;
}

- (NSDecimalNumber *)hy_decimalNumberByMultiplyingBy:(NSDecimalNumber *)decimalNumber {

    if ([self checkWithDecimalNumber:decimalNumber]) {
        return [self hy_decimalNumberByMultiplyingBy:decimalNumber];
    }
    hy_crashHookLog(NSDecimalNumber.class, _cmd, @"notANumber");
    return nil;
}

- (NSDecimalNumber *)hy_decimalNumberByDividingBy:(NSDecimalNumber *)decimalNumber {

    if ([self checkWithDecimalNumber:decimalNumber]) {
        return [self hy_decimalNumberByDividingBy:decimalNumber];
    }
    hy_crashHookLog(NSDecimalNumber.class, _cmd, @"notANumber");
    return nil;
}

- (BOOL)checkWithDecimalNumber:(NSDecimalNumber *)decimalNumber {
    return
    ![self isEqualToNumber:NSDecimalNumber.notANumber] &&
    ![decimalNumber isEqualToNumber:NSDecimalNumber.notANumber];
}

@end
