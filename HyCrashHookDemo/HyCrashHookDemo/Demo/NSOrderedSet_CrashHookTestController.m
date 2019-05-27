//
//  NSOrderedSet_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSOrderedSet_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSOrderedSet_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSOrderedSet.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    
    NSOrderedSet *setOne = [NSOrderedSet orderedSetWithArray:@[@1,@2, @2,@3,@3]];
    id objectOne = [setOne objectAtIndex:4];
    NSLog(@"setOne:%@, objectOne:%@",setOne, objectOne);
    
    
    NSOrderedSet *setTwo = [NSOrderedSet orderedSetWithArray:@[@1,@2, @2,@3,@3]
                                                       range:NSMakeRange(0, 5)
                                                   copyItems:NO];
    NSLog(@"setTwo:%@", setTwo);
}

@end
