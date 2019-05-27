//
//  NSMutableAttributedString+CrashHook.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/13.
//  Copyright © 2019 huangyi. All rights reserved.
//


#import "NSMutableAttributedString+CrashHook.h"
#import "HyCrashHookLogger.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableAttributedString (CrashHook)

+ (void)hy_openCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"NSConcreteMutableAttributedString");
        hy_swizzleInstanceMethods(cls, @[@"initWithString:",
                                         @"initWithString:attributes:",
                                         @"addAttribute:value:range:",
                                         @"addAttributes:range:",
                                         @"setAttributes:range:",
                                         @"removeAttribute:range:",
                                         @"deleteCharactersInRange:",
                                         @"replaceCharactersInRange:withString:",
                                         @"replaceCharactersInRange:withAttributedString:"]);
    });
}

- (id)hy_initWithString:(NSString*)str {
    
    if (str){
        return [self hy_initWithString:str];
    }
    hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"parameter nil");
    return nil;
}

- (id)hy_initWithString:(NSString*)str attributes:(nullable NSDictionary*)attributes {
    
    if (str){
        return [self hy_initWithString:str attributes:attributes];
    }
    hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"parameter nil");
    return nil;
}

- (void)hy_addAttribute:(id)name value:(id)value range:(NSRange)range {
    
    if (!range.length) {
        [self hy_addAttribute:name value:value range:range];
    } else if (value) {
        if (range.location + range.length <= self.length) {
            [self hy_addAttribute:name value:value range:range];
        } else {
           hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"name:%@ value:%@ range:%@",name,value,NSStringFromRange(range)]);
        }
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"value nil");
    }
}

- (void)hy_addAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range {
    
    if (!range.length) {
        [self hy_addAttributes:attrs range:range];
    }else if (attrs){
        if (range.location + range.length <= self.length) {
            [self hy_addAttributes:attrs range:range];
        } else {
            hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"attrs:%@ range:%@",attrs,NSStringFromRange(range)]);
        }
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"value nil");
    }
}

- (void)hy_setAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range {
    
    if (!range.length) {
        [self hy_setAttributes:attrs range:range];
    }else if (attrs) {
        if (range.location + range.length <= self.length) {
            [self hy_setAttributes:attrs range:range];
        } else {
            hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"attrs:%@ range:%@",attrs,NSStringFromRange(range)]);
        }
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"attrs nil");
    }
}

- (void)hy_removeAttribute:(id)name range:(NSRange)range {
    
    if (!range.length) {
        [self hy_removeAttribute:name range:range];
    } else if (name){
        if (range.location + range.length <= self.length) {
            [self hy_removeAttribute:name range:range];
        }else {
            hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"name:%@ range:%@",name,NSStringFromRange(range)]);
        }
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"attrs nil");
    }
}

- (void)hy_deleteCharactersInRange:(NSRange)range {
    
    if (range.location + range.length <= self.length) {
        [self hy_deleteCharactersInRange:range];
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"range:%@",NSStringFromRange(range)]);
    }
}

- (void)hy_replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    
    if (str){
        if (range.location + range.length <= self.length) {
            [self hy_replaceCharactersInRange:range withString:str];
        }else{
            hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"string:%@ range:%@",str,NSStringFromRange(range)]);
        }
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"string nil");
    }
}

- (void)hy_replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)str {
    
    if (str){
        if (range.location + range.length <= self.length) {
            [self hy_replaceCharactersInRange:range withAttributedString:str];
        } else {
           hy_crashHookLog(NSMutableAttributedString.class, _cmd, [NSString stringWithFormat:@"string:%@ range:%@",str,NSStringFromRange(range)]);
        }
    } else {
        hy_crashHookLog(NSMutableAttributedString.class, _cmd, @"attributedString nil");
    }
}

@end
