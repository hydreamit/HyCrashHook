//
//  NSData_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSData_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSData_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSData.class] 
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
    
    NSData *data = [NSData data];
    NSData *dataOne = [data subdataWithRange:NSMakeRange(0, 3)];
    NSLog(@"dataOne:%@", dataOne);

    NSRange range = [data rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, 3)];
    NSLog(@"%@", NSStringFromRange(range));
}

@end
