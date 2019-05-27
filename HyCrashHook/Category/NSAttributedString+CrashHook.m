//
//  NSAttributedString+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSAttributedString+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSAttributedString (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"NSConcreteAttributedString");
        hy_swizzleInstanceMethods(cls, @[@"initWithString:",
                                         @"attributedSubstringFromRange:",
                                         @"attribute:atIndex:effectiveRange:",
                                         @"enumerateAttribute:inRange:options:usingBlock:",
                                         @"enumerateAttributesInRange:options:usingBlock:"]);
    });
}

- (id)hy_initWithString:(NSString*)str {
    
    if (str) {
        return [self hy_initWithString:str];
    }
    hy_crashHookLog(NSAttributedString.class, _cmd, @"parameter nil");
    return nil;
}

- (id)hy_attribute:(NSAttributedStringKey)attrName atIndex:(NSUInteger)location effectiveRange:(nullable NSRangePointer)range {
    
    if (location < self.length) {
        return [self hy_attribute:attrName atIndex:location effectiveRange:range];
    }
    hy_crashHookLog(NSAttributedString.class, _cmd, [NSString stringWithFormat:@"attrName:%@ location:%tu",attrName,location]);
    return nil;
}

- (NSAttributedString *)hy_attributedSubstringFromRange:(NSRange)range {
    
    if (range.location + range.length <= self.length) {
        return [self hy_attributedSubstringFromRange:range];
    }
    hy_crashHookLog(NSAttributedString.class, _cmd, [NSString stringWithFormat:@"range:%@",NSStringFromRange(range)]);
    return nil;
}

- (void)hy_enumerateAttribute:(NSString *)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id _Nullable, NSRange, BOOL * _Nonnull))block {
    
    if (range.location + range.length <= self.length) {
        [self hy_enumerateAttribute:attrName inRange:range options:opts usingBlock:block];
    } else {
        hy_crashHookLog(NSAttributedString.class, _cmd, [NSString stringWithFormat:@"attrName:%@ range:%@",attrName,NSStringFromRange(range)]);
    }
}

- (void)hy_enumerateAttributesInRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary<NSString*,id> * _Nonnull, NSRange, BOOL * _Nonnull))block {
    
    if (range.location + range.length <= self.length) {
        [self hy_enumerateAttributesInRange:range options:opts usingBlock:block];
    } else {
        hy_crashHookLog(NSAttributedString.class, _cmd, [NSString stringWithFormat:@"range:%@",NSStringFromRange(range)]);
    }
}

@end
