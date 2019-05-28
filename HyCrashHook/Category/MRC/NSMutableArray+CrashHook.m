//
//  NSMutableArray+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableArray+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableArray (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // NSMutableArray EthnicAroups // MRC @"__NSCFArray"
        NSArray<NSString *> *ethnicAroups = @[@"__NSArrayM", @"__NSCFArray"];
        
        // swizzleInstanceMethods
        NSArray<NSString *> *swizzleInstanceMethods = @[@"objectAtIndex:",
                                                        @"objectAtIndexedSubscript:",
                                                        @"subarrayWithRange:",
                                                        @"setObject:atIndexedSubscript:",
                                                        @"ddObject:",
                                                        @"insertObject:atIndex:",
                                                        @"insertObjects:atIndexes:",
                                                        @"removeObjectAtIndex:",
                                                        @"removeObjectsInRange:",
                                                        @"replaceObjectAtIndex:withObject:",
                                                        @"replaceObjectsAtIndexes:withObjects:",
                                                        @"replaceObjectsInRange:withObjectsFromArray:"
                                                        ];
        
        hy_swizzleInstanceMethods(ethnicAroups, swizzleInstanceMethods);
    });
}

- (id)hy_objectAtIndex:(NSUInteger)index {
    
    if ([self chenckIndex:index]) {
        return [self hy_objectAtIndex:index];
    }
    hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    return nil;
}

- (id)hy_objectAtIndexedSubscript:(NSUInteger)index {
    
    if ([self chenckIndex:index]) {
        return [self hy_objectAtIndexedSubscript:index];
    }
    hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    return nil;
}

- (NSArray *)hy_subarrayWithRange:(NSRange)range {
    
    if (range.location + range.length <= self.count){
        return [self hy_subarrayWithRange:range];
    }else if (range.location < self.count){
        return [self hy_subarrayWithRange:NSMakeRange(range.location, self.count-range.location)];
    }
    hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid range location:%tu length:%tu",range.location,range.length]);
    return nil;
}

- (void)hy_setObject:(id)object atIndexedSubscript:(NSUInteger)index {
    
    if ([self chenckIndex:index] && object) {
        [self hy_setObject:object atIndexedSubscript:index];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid object:%@ atIndexedSubscript:%tu total:%tu",object,index,self.count]);
    }
}

- (void)hy_addObject:(id)anObject {
    
    if (anObject) {
        [self hy_addObject:anObject];
    } else {
       hy_crashHookLog(NSMutableArray.class, _cmd, @"nil object");
    }
}

- (void)hy_insertObject:(id)anObject atIndex:(NSUInteger)index {
    
    if (anObject && index <= self.count && index >= 0) {
        [self hy_insertObject:anObject atIndex:index];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu insert object:%@",index,self.count,anObject]);
    }
}

- (void)hy_insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    
    if (objects && indexes.count == objects.count && indexes.firstIndex <= self.count) {
        [self hy_insertObjects:objects atIndexes:indexes];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid objects:%@ indexes:%@ total:%tu",objects, indexes, self.count]);
    }
}

- (void)hy_removeObjectAtIndex:(NSUInteger)index {
    
    if ([self chenckIndex:index]) {
        [self hy_removeObjectAtIndex:index];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    }
}

- (void)hy_removeObjectsInRange:(NSRange)range {
    
    if (range.location + range.length <= self.count) {
        [self hy_removeObjectsInRange:range];
    } else {
       hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid range location:%tu length:%tu",range.location,range.length]);
    }
}

- (void)hy_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    if ([self chenckIndex:index] && anObject) {
        [self hy_replaceObjectAtIndex:index withObject:anObject];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu replace object:%@",index,self.count,anObject]);
    }
}

- (void)hy_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    
    if (indexes.firstIndex < self.count && indexes.lastIndex < self.count) {
        [self hy_replaceObjectsAtIndexes:indexes withObjects:objects];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid indexes:%@ objects:%@ total:%tu",indexes, objects, self.count]);
    }
}

- (void)hy_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    
    if (range.location + range.length <= self.count) {
        [self hy_replaceObjectsInRange:range withObjectsFromArray:otherArray];
    } else {
        hy_crashHookLog(NSMutableArray.class, _cmd, [NSString stringWithFormat:@"invalid range location:%tu length:%tu otherArray:%@",range.location,range.length, otherArray]);
    }
}

- (BOOL)chenckIndex:(NSUInteger)index {
    return index >= 0 && index < self.count;
}

@end
