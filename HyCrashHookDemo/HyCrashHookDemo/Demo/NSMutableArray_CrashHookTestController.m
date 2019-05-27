//
//  NSMutableArray_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableArray_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableArray_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSArray.class, NSMutableArray.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    
    [self test_initMutableArray];
    [self test_getObject];
    [self test_insertObject];
    [self test_removeObject];
    [self test_replaceObject];
}

/*
 @"arrayWithObject:",
 @"arrayWithObjects:",
 */
- (void)test_initMutableArray {
    
    NSMutableArray *arrayOne = @[[self nilObject]].mutableCopy;
    NSMutableArray *arrayTwo = [NSMutableArray arrayWithObject:[self nilObject]];
    NSLog(@"arrayOne:%@, arrayTwo:%@",arrayOne, arrayTwo);
}

/*
 @"objectAtIndex:",
 @"objectAtIndexedSubscript:",
 @"subarrayWithRange:",
 */
- (void)test_getObject {
    
    NSMutableArray *array = @[@"1",@"2",@"3"].mutableCopy;
    id objectOne = [array objectAtIndex:4];
    id objectTwo = [array objectAtIndexedSubscript:5];
    NSArray *rangeArray = [array subarrayWithRange:NSMakeRange(1, 5)];
    NSLog(@"objectOne:%@, objectTwo:%@, rangeArray:%@", objectOne, objectTwo, rangeArray);
}

/*
 @"setObject:atIndexedSubscript:",
 @"ddObject:",
 @"insertObject:atIndex:",
 @"insertObjects:atIndexes:",
 */
- (void)test_insertObject {
    
    NSMutableArray *array = @[@"1",@"2",@"3"].mutableCopy;
    [array setObject:[self nilObject] atIndexedSubscript:1];
    [array setObject:@"4" atIndexedSubscript:5];
    [array addObject:[self nilObject]];
    [array insertObject:[self nilObject] atIndex:2];
    [array insertObject:@"4" atIndex:4];
    [array insertObjects:@[@"4",@"5",@"6"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 6)]];
    [array insertObjects:@[@"4",@"5",@"6"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    NSLog(@"array:%@", array);
}

/*
 @"removeObjectAtIndex:",
 @"removeObjectsInRange:",
 */
- (void)test_removeObject {
    
    NSMutableArray *array = @[@"1",@"2",@"3"].mutableCopy;
    [array removeObjectAtIndex:3];
    [array removeObjectsInRange:NSMakeRange(0, 4)];
    NSLog(@"array:%@", array);
}

/*
 @"replaceObjectAtIndex:withObject:",
 @"replaceObjectsAtIndexes:withObjects:",
 @"replaceObjectsInRange:withObjectsFromArray:"
 */
- (void)test_replaceObject {
    
    NSMutableArray *array = @[@"1",@"2",@"3"].mutableCopy;
    [array replaceObjectAtIndex:3 withObject:@"4"];
    [array replaceObjectAtIndex:3 withObject:[self nilObject]];
    [array replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]
                       withObjects:@[@"4", @"5", @"6"]];
    [array replaceObjectsInRange:NSMakeRange(1, 4) withObjectsFromArray:@[@"4", @"5", @"6"]];
    NSLog(@"array:%@", array);
}

- (id)nilObject {
    return nil;
}

@end
