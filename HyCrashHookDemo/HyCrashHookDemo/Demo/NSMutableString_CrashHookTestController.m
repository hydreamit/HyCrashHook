//
//  NSMutableString_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableString_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableString_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSString.class, NSMutableString.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    
    NSString *nilString = nil;
    NSMutableString *string = [NSMutableString stringWithFormat:@"12345"];
    
    [string appendString:nilString];
    NSLog(@"appendString:%@", string);
    
    [string insertString:nilString atIndex:5];
    NSLog(@"insertString:%@", string);
    
    [string insertString:@"6" atIndex:6];
    NSLog(@"insertString:%@", string);
    
    [string deleteCharactersInRange:NSMakeRange(3, 6)];
    NSLog(@"deleteCharactersInRange:%@", string);
    
    [string deleteCharactersInRange:NSMakeRange(3, 3)];
    NSLog(@"deleteCharactersInRange:%@", string);
}

@end
