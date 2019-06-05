//
//  NSDecimalNumber_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSDecimalNumber_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSDecimalNumber_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // subscribe hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSDecimalNumber.class] 
                                            block:^(Class  _Nullable __unsafe_unretained cls,
                                                    NSString * _Nullable location,
                                                    NSString * _Nullable description,
                                                    NSArray<NSString *> * _Nullable callStack) {
        
        NSLog(@"subscribeCrash Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHandler:crashHandler];
    });
    
    NSDecimalNumber *numberOne = [NSDecimalNumber decimalNumberWithString:@""];
    NSDecimalNumber *numberTwo = [NSDecimalNumber decimalNumberWithString:@"1"];
    
    NSDecimalNumber *addingNumber = [numberOne decimalNumberByAdding:numberTwo];
    NSLog(@"addingNumber:%@", addingNumber);
    
    NSDecimalNumber *subtractingNumber = [numberOne decimalNumberBySubtracting:numberTwo];
    NSLog(@"subtractingNumber:%@", subtractingNumber);
    
    NSDecimalNumber *multiplyingNumber = [numberOne decimalNumberByMultiplyingBy:numberTwo];
    NSLog(@"multiplyingNumber:%@", multiplyingNumber);
    
    NSDecimalNumber *dividingNumber = [numberOne decimalNumberByDividingBy:numberTwo];
    NSLog(@"dividingNumber:%@", dividingNumber);
}

@end
