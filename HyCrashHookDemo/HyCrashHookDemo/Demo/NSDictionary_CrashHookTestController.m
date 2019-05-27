//
//  NSDictionary_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSDictionary_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSDictionary_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe only NSDictionary hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSDictionary.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    NSString *value = nil;
    NSString *key = nil;
    
    NSDictionary *dic = @{@"key":value};
    dic = @{key:@"value"};
    
    dic = [NSDictionary dictionaryWithObject:@"value" forKey:key];
    dic = [NSDictionary dictionaryWithObject:value forKey:@"key"];
    
    dic = @{@"keyOne" : @"123",
            @"keyTwo" : value,
            key : @"123",
            key : @"value"
            };
    
    NSLog(@"dic:%@", dic);
}

@end
