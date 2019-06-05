//
//  NSArray_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSArray_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSArray_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe only NSArray hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSArray.class] 
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
 
    [self test_initArray];
    [self test_getObject];
}


/*
 @"arrayWithObject:",
 @"arrayWithObjects:count",
 */
- (void)test_initArray {
    
    NSArray *arrayOne = @[[self nilObject]];
    NSArray *arrayTwo = [NSArray arrayWithObject:[self nilObject]];
    NSLog(@"arrayOne:%@, arrayTwo:%@", arrayOne, arrayTwo);
}


/*
 @"objectAtIndex:",
 @"objectAtIndexedSubscript:",
 @"subarrayWithRange:",
 */
- (void)test_getObject {
    
    NSArray *array = @[@"1",@"2",@"3"];
    id objectOne = [array objectAtIndex:4];
    id objectTwo = [array objectAtIndexedSubscript:5];
    NSArray *rangeArray = [array subarrayWithRange:NSMakeRange(1, 5)];
    NSLog(@"arrayOne:%@, arrayTwo:%@, rangeArray:%@", objectOne, objectTwo, rangeArray);
}

- (id)nilObject {
    return nil;
}

@end
