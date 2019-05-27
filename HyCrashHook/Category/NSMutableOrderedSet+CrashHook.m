//
//  NSMutableOrderedSet+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableOrderedSet+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@implementation NSMutableOrderedSet (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSClassFromString(@"__NSOrderedSetM"), @[@"objectAtIndex:",
                                                                           @"addObject:",
                                                                           @"insertObject:atIndex:",
                                                                           @"insertObjects:atIndexes:",
                                                                           @"removeObjectAtIndex:",
                                                                           @"replaceObjectAtIndex:withObject:",
                                                                           @"replaceObjectsAtIndexes:withObjects:"]);
    });
}

- (id)hy_objectAtIndex:(NSUInteger)idx {
    
    if (idx <= self.count && index >= 0) {
       return [self hy_objectAtIndex:idx];
    }
    hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    return nil;
}

- (void)hy_addObject:(id)object{
    
    if (object) {
        [self hy_addObject:object ];
    } else {
        hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"nil object"]);
    }
}

- (void)hy_insertObject:(id)anObject atIndex:(NSUInteger)index {
    
    if (anObject && index <= self.count && index >= 0) {
        [self hy_insertObject:anObject atIndex:index];
    } else {
        hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu insert object:%@",index,self.count,anObject]);
    }
}

- (void)hy_insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    
    if (objects.count == indexes.count) {
        [self hy_insertObjects:objects atIndexes:indexes];
    } else {
        hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"count of array (%tu) differs from count of index set (%tu)", objects.count, indexes.count]);
    }
}

- (void)hy_removeObjectAtIndex:(NSUInteger)index {
    
    if (index <= self.count && index >= 0) {
        [self hy_removeObjectAtIndex:index];
    } else {
       hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    }
}

- (void)hy_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    if (anObject && index <= self.count && index >= 0) {
        [self hy_replaceObjectAtIndex:index withObject:anObject];
    } else {
        hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu insert object:%@",index,self.count,anObject]);
    }
}

- (void)hy_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    
    if (indexes.count == objects.count) {
        [self hy_replaceObjectsAtIndexes:indexes withObjects:objects];
    } else {
        hy_crashHookLog(NSMutableOrderedSet.class, _cmd, [NSString stringWithFormat:@"count of array (%tu) differs from count of index set (%tu)", objects.count, indexes.count]);
    }
}

@end
