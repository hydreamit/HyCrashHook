//
//  NSUserDefaults_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSUserDefaults_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSUserDefaults_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSUserDefaults.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    NSString *nilKey = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"%@", [userDefaults objectForKey:nilKey]);
    NSLog(@"%@", [userDefaults arrayForKey:nilKey]);
    NSLog(@"%@", [userDefaults dataForKey:nilKey]);
    NSLog(@"%@", [userDefaults URLForKey:nilKey]);
    NSLog(@"%@", [userDefaults stringArrayForKey:nilKey]);
    NSLog(@"%f", [userDefaults floatForKey:nilKey]);
    NSLog(@"%f", [userDefaults doubleForKey:nilKey]);
    NSLog(@"%tu", [userDefaults integerForKey:nilKey]);
    NSLog(@"%tu", [userDefaults boolForKey:nilKey]);
    
    [userDefaults setObject:@1 forKey:nilKey];
}

@end
