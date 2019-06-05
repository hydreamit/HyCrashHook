//
//  NSMutableDictionary_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableDictionary_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableDictionary_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // subscribe hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSDictionary.class, NSMutableDictionary.class] 
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
    
    
    NSString *value = nil;
    NSString *key = nil;
    
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    dicM[@"keyOne"] = @"123";
    dicM[key] = value;
    [dicM setObject:@"value" forKey:key];
    [dicM setObject:value forKey:@"key"];
    NSLog(@"dicM:%@",dicM);
    
    [dicM removeObjectForKey:key];
    NSLog(@"dicM:%@",dicM);
}

@end
