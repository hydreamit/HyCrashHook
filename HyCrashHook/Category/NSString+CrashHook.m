//
//  NSString+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/13.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookLogger.h"
#import "NSString+CrashHook.h"
#import "HyCrashHookMethods.h"


@implementation NSString (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethods(NSString.class, @[@"stringWithUTF8String:", @"stringWithCString:encoding:"]);
        
        //NSPlaceholderString
        hy_swizzleInstanceMethods(NSClassFromString(@"NSPlaceholderString"), @[@"initWithString:",
                                                                               @"initWithCString:encoding:"]);
        
        // NSString EthnicAroups
        NSArray<NSString *> *ethnicAroups = @[@"__NSCFConstantString",
                                              @"NSTaggedPointerString"];
        
        // swizzleInstanceMethods
        NSArray<NSString *> *swizzleInstanceMethods = @[@"hasPrefix:",
                                                        @"hasSuffix:",
                                                        @"stringByAppendingString:",
                                                        @"stringByAppendingFormat:",
                                                        @"substringFromIndex:",
                                                        @"substringToIndex:",
                                                        @"substringWithRange:",
                                                        @"rangeOfString:options:range:locale:",
                                                        @"stringByReplacingOccurrencesOfString:withString:options:range:",
                                                        @"stringByReplacingCharactersInRange:withString:",
                                                        @"stringByReplacingOccurrencesOfString:withString:"
                                                        ];
        
        hy_swizzleInstanceMethods(ethnicAroups, swizzleInstanceMethods);
    });
}

+ (NSString *)hy_stringWithUTF8String:(const char *)nullTerminatedCString {
    
    if (NULL != nullTerminatedCString) {
        return [self hy_stringWithUTF8String:nullTerminatedCString];
    }
    hy_crashHookLog(NSString.class, _cmd, @"NULL char pointer");
    return nil;
}

+ (nullable instancetype)hy_stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc {
    
    if (NULL != cString){
        return [self hy_stringWithCString:cString encoding:enc];
    }
    hy_crashHookLog(NSString.class, _cmd, @"NULL char pointer");
    return nil;
}

- (nullable instancetype)hy_initWithString:(id)cString {
    
    if (nil != cString){
        return [self hy_initWithString:cString];
    }
    hy_crashHookLog(NSString.class, _cmd, @"nil parameter");
    return nil;
}

- (nullable instancetype)hy_initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    
    if (NULL != nullTerminatedCString){
        return [self hy_initWithCString:nullTerminatedCString encoding:encoding];
    }
    hy_crashHookLog(NSString.class, _cmd, @"NULL char pointer");
    return nil;
}

- (BOOL)hy_hasPrefix:(NSString *)str {
    
    if (nil != str) {
        return [self hy_hasPrefix:str];
    }
    hy_crashHookLog(NSString.class, _cmd, @"nil parameter");
    return NO;
}

- (BOOL)hy_hasSuffix:(NSString *)str {
    
    if (nil != str) {
        return [self hy_hasSuffix:str];
    }
    hy_crashHookLog(NSString.class, _cmd, @"nil parameter");
    return NO;
}

- (NSString *)hy_stringByAppendingString:(NSString *)aString {
    
    if (nil != aString) {
        return [self hy_stringByAppendingString:aString];
    }
    hy_crashHookLog(NSString.class, _cmd, @"nil parameter");
    return self;
}

- (NSString *)hy_stringByAppendingFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    
    if (nil != format) {
        return [self hy_stringByAppendingFormat:@"%@", format];
    }
    hy_crashHookLog(NSString.class, _cmd, @"nil parameter");
    return self;
}

- (NSString *)hy_substringFromIndex:(NSUInteger)from {
    
    if (from <= self.length) {
        return [self hy_substringFromIndex:from];
    }
    hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"value:%@ from:%tu",self,from]);
    return nil;
}

- (NSString *)hy_substringToIndex:(NSUInteger)to {
    
    if (to <= self.length) {
        return [self hy_substringToIndex:to];
    }
    hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"value:%@ to:%tu",self,to]);
    return self;
}

- (NSString *)hy_substringWithRange:(NSRange)range {
    
    if (range.location + range.length <= self.length) {
        return [self hy_substringWithRange:range];
    }
    hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"value:%@ range:%@",self,NSStringFromRange(range)]);
    return nil;
}

- (NSRange)hy_rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(nullable NSLocale *)locale {
    
    if (searchString) {
        if (range.location + range.length <= self.length) {
            return [self hy_rangeOfString:searchString options:mask range:range locale:locale];
        }
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"value:%@ range:%@",self,NSStringFromRange(range)]);
        return NSMakeRange(NSNotFound, 0);
    } else {
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"searchString nil value:%@ range:%@",self,NSStringFromRange(range)]);
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSString *)hy_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) {
    
    if (target != nil && replacement != nil) {
        if (searchRange.location + searchRange.length <= self.length) {
            return [self hy_stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
        }
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"value:%@ range:%@",self,NSStringFromRange(searchRange)]);
        
        return self;
    } else {
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"target:%@ replacement:%@",target,replacement]);
        return self;
    }
}

- (NSString *)hy_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) {
    
    if (target != nil && replacement != nil) {
        return [self hy_stringByReplacingOccurrencesOfString:target withString:replacement];
    } else {
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"target:%@ replacement:%@",target,replacement]);
        return self;
    }
}

- (NSString *)hy_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) {
    
    if (replacement != nil) {
        if (range.location + range.length <= self.length) {
            return [self hy_stringByReplacingCharactersInRange:range withString:replacement];
        }
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"value:%@ range:%@",self,NSStringFromRange(range)]);
        return self;
    } else {
        hy_crashHookLog(NSString.class, _cmd, [NSString stringWithFormat:@"replacement nil value:%@ range:%@",self,NSStringFromRange(range)]);
        return self;
    }
}
@end
