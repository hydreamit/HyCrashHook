//
//  NSMutableOrderedSet_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableOrderedSet_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableOrderedSet_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // subscribe hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSMutableOrderedSet.class] 
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
    NSMutableOrderedSet *setOne = [NSMutableOrderedSet orderedSetWithArray:@[@1,@2, @2,@3,@3]];
    NSLog(@"setOne:%@", setOne);
    
    [setOne objectAtIndex:5];
    [setOne addObject:nilObject];
    [setOne removeObjectAtIndex:5];
    NSLog(@"setOne:%@", setOne);

    [setOne insertObject:@3 atIndex:5];
    [setOne insertObjects:nilObject atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
    NSLog(@"setOne:%@", setOne);
    
    [setOne replaceObjectAtIndex:1 withObject:nilObject];
    [setOne replaceObjectAtIndex:4 withObject:@1];
    [setOne replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
                        withObjects:@[@1]];
    NSLog(@"setOne:%@", setOne);
}

@end
