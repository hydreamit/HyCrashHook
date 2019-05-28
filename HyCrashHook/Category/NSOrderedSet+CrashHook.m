//
//  NSOrderedSet+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSOrderedSet+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@implementation NSOrderedSet (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        hy_swizzleClassMethods(NSOrderedSet.class, @[@"initWithArray:range:copyItems:"]);
        
        NSArray<NSString *> *ethnicAroups = @[@"__NSOrderedSetI",
                                              @"__NSPlaceholderSet",
                                              @"__NSPlaceholderOrderedSet"];
        
        hy_swizzleInstanceMethods(ethnicAroups, @[@"objectAtIndex:",
                                                  @"initWithObjects:count:"]);
    });
}

+ (instancetype)hy_orderedSetWithArray:(NSArray *)array range:(NSRange)range copyItems:(BOOL)flag {

    if (range.location + range.length <= array.count) {
        return [self hy_orderedSetWithArray:array range:range copyItems:flag];
    }
     hy_crashHookLog(NSOrderedSet.class, _cmd, [NSString stringWithFormat:@"arrayCount:%tu rangeLocation:%tu rangeLength:%tu", (unsigned long)array.count, (unsigned long)range.location, range.length]);
    return nil;
}

- (id)hy_objectAtIndex:(NSUInteger)idx {
    
    if (idx >= 0 && idx < self.count) {
        return [self hy_objectAtIndex:idx];
    }
    hy_crashHookLog(NSOrderedSet.class, _cmd, [NSString stringWithFormat:@"idx:%tu count:%tu", (unsigned long)idx, (unsigned long)self.count]);
    return nil;
}

- (instancetype)hy_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    
    NSInteger index = 0;
    id objs[cnt];
    for (NSInteger i = 0; i < cnt ; ++i) {
        if (objects[i]) {
            objs[index++] = objects[i];
        } else {
            hy_crashHookLog(NSOrderedSet.class, _cmd, [NSString stringWithFormat:@"invalid index object:%tu total:%tu",i,cnt]);
        }
    }
    return [self hy_initWithObjects:objs count:index];
}


@end
