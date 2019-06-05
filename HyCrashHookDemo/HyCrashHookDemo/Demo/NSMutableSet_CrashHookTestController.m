//
//  NSMutableSet_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableSet_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableSet_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSSet.class, NSMutableSet.class] 
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
    
    id nilObject = nil;
    NSMutableSet *set = [NSMutableSet setWithObject:@"1"];
    [set addObject:nilObject];
    [set removeObject:nilObject];
    NSLog(@"%@", set);
}

@end
