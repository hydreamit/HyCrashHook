//
//  NSMutableString+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/13.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableString+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableString (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethods(NSClassFromString(@"__NSCFString"), @[@"appendString:",
                                                                        @"insertString:atIndex:",
                                                                        @"deleteCharactersInRange:",
                                                                        @"substringFromIndex:",
                                                                        @"substringToIndex:",
                                                                        @"substringWithRange:"]);
    });
}

- (void)hy_appendString:(NSString *)aString {
    
    if (aString) {
        [self hy_appendString:aString];
    } else {
        hy_crashHookLog(NSMutableString.class, _cmd, [NSString stringWithFormat:@"value:%@ parameter nil",self]);
    }
}

- (void)hy_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    
    if (aString && loc <= self.length) {
        [self hy_insertString:aString atIndex:loc];
    } else {
       hy_crashHookLog(NSMutableString.class, _cmd, [NSString stringWithFormat:@"value:%@ paremeter string:%@ atIndex:%tu",self,aString,loc]);
    }
}

- (void)hy_deleteCharactersInRange:(NSRange)range {
    
    if (range.location + range.length <= self.length){
        [self hy_deleteCharactersInRange:range];
    } else {
        hy_crashHookLog(NSMutableString.class, _cmd, [NSString stringWithFormat:@"value:%@ range:%@",self,NSStringFromRange(range)]);
    }
}

- (NSString *)hy_substringFromIndex:(NSUInteger)from {
    
    if (from <= self.length) {
        return [self hy_substringFromIndex:from];
    }
    hy_crashHookLog(NSMutableString.class, _cmd, [NSString stringWithFormat:@"value:%@ from:%tu",self,from]);
    return nil;
}

- (NSString *)hy_substringToIndex:(NSUInteger)to {
    
    if (to <= self.length) {
        return [self hy_substringToIndex:to];
    }
    hy_crashHookLog(NSMutableString.class, _cmd, [NSString stringWithFormat:@"value:%@ to:%tu",self,to]);
    return self;
}

- (NSString *)hy_substringWithRange:(NSRange)range {
    
    if (range.location + range.length <= self.length) {
        return [self hy_substringWithRange:range];
    }
    hy_crashHookLog(NSMutableString.class, _cmd, [NSString stringWithFormat:@"value:%@ range:%@",self,NSStringFromRange(range)]);
    return nil;
}

@end
