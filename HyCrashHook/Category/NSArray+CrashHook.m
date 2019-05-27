//
//  NSArray+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookLogger.h"
#import "NSArray+CrashHook.h"
#import "HyCrashHookMethods.h"


@implementation NSArray (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethods(NSArray.class, @[@"arrayWithObject:", @"arrayWithObjects:count:"]);
        
        // NSArray EthnicAroups
        NSArray<NSString *> *ethnicAroups = @[@"__NSArray0",
                                              @"__NSSingleObjectArrayI",
                                              @"__NSArrayI",
                                              @"__NSFrozenArrayM",
                                              @"__NSArrayReversed",
                                              @"__NSArrayI_Transfer"];

        // swizzleInstanceMethods
        NSArray<NSString *> *swizzleInstanceMethods = @[@"objectAtIndex:",
                                                        @"subarrayWithRange:",
                                                        @"objectAtIndexedSubscript:"];
        
        hy_swizzleInstanceMethods(ethnicAroups, swizzleInstanceMethods);
    });
}

+ (instancetype)hy_arrayWithObject:(id)anObject {
    
    if (anObject) {
        return [self hy_arrayWithObject:anObject];
    }
    hy_crashHookLog(NSArray.class, _cmd, @"object is nil");
    return nil;
}

+ (instancetype)hy_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt {
    
    NSInteger index = 0;
    id objs[cnt];
    for (NSInteger i = 0; i < cnt ; ++i) {
        if (objects[i]) {
            objs[index++] = objects[i];
        } else {
            hy_crashHookLog(NSArray.class, _cmd, [NSString stringWithFormat:@"invalid index object:%tu total:%tu",i,cnt]);
        }
    }
    return [self hy_arrayWithObjects:objs count:index];
}

- (id)hy_objectAtIndex:(NSUInteger)index {
    
    if (index < self.count) {
        return [self hy_objectAtIndex:index];
    }
    hy_crashHookLog(NSArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    return nil;
}

- (id)hy_objectAtIndexedSubscript:(NSInteger)index {
    
    if (index < self.count) {
        return [self hy_objectAtIndexedSubscript:index];
    }
    hy_crashHookLog(NSArray.class, _cmd, [NSString stringWithFormat:@"invalid index:%tu total:%tu",index,self.count]);
    return nil;
}

- (NSArray *)hy_subarrayWithRange:(NSRange)range {
    
    if (range.location + range.length <= self.count) {
        return [self hy_subarrayWithRange:range];
    } else if (range.location < self.count){
        return [self hy_subarrayWithRange:NSMakeRange(range.location, self.count-range.location)];
    }
    hy_crashHookLog(NSArray.class, _cmd, [NSString stringWithFormat:@"invalid range location:%tu length:%tu",range.location, range.length]);
    return nil;
}

@end
