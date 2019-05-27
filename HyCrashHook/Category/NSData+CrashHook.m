//
//  NSData+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/16.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSData+CrashHook.h"
#import "HyCrashHookMethods.h"
#import "HyCrashHookLogger.h"


@implementation NSData (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // NSData EthnicAroups
        NSArray<NSString *> *ethnicAroups = @[@"NSConcreteData",
                                              @"_NSZeroData",
                                              @"_NSInlineData",
                                              @"__NSCFData"];
        
        // swizzleInstanceMethods
        NSArray<NSString *> *swizzleInstanceMethods = @[@"subdataWithRange:",
                                                        @"rangeOfData:options:range:"];
        
        hy_swizzleInstanceMethods(ethnicAroups, swizzleInstanceMethods);
    });
}

- (NSData *)hy_subdataWithRange:(NSRange)range {
    
    if (range.location + range.length <= self.length) {
        return [self hy_subdataWithRange:range];
    } else if (range.location < self.length) {
        return [self hy_subdataWithRange:NSMakeRange(range.location, self.length - range.location)];
    }
    hy_crashHookLog(NSData.class, _cmd, [NSString stringWithFormat:@"invalid range location:%tu length:%tu", range.location, range.length]);
    return nil;
}

- (NSRange)hy_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    
    if (dataToFind == nil && (searchRange.location + searchRange.length <= self.length)) {
        return [self hy_rangeOfData:dataToFind options:mask range:searchRange];
    }
    hy_crashHookLog(NSData.class, _cmd, [NSString stringWithFormat:@"invalid dataToFind:%@ location:%tu dataToFind,  length:%tu",dataToFind, (unsigned long)searchRange.location, searchRange.length]);
    return NSMakeRange(NSNotFound, 0);
}
@end
