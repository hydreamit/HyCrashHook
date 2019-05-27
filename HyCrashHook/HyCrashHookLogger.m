//
//  HyCrashHookLogger.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookLogger.h"
#import "HyCrashHookManager.h"


NSString *getLocation(NSArray<NSString *> *callStackSymbols){

    __block NSString *mainCallStackSymbolMsg = nil;
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (int index = 2; index < callStackSymbols.count; index++) {
        
        NSString *callStackSymbol = callStackSymbols[index];
        
        [regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                
                //filter category and system class
                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                }
                *stop = YES;
            }
        }];
        
        if (mainCallStackSymbolMsg.length) {
            break;
        }
    }
    return mainCallStackSymbolMsg ?: @"崩溃方法定位失败,请您查看函数调用栈来排查错误原因";
};


NSString *hy_getMethodString(SEL swizzledMethod) {
    
    NSString *swizzledMethodString = NSStringFromSelector(swizzledMethod);
    if ([swizzledMethodString hasPrefix:@"hy_"]) {
        return [swizzledMethodString substringFromIndex:3];
    }
    return swizzledMethodString;
}

void hy_crashHookLog(Class cls, SEL sel, NSString *message) {
    
    BOOL isObjectClass = [message hasPrefix:@"isObjectClass"];
    if (isObjectClass) {
        message = [message stringByReplacingOccurrencesOfString:@"isObjectClass " withString:@""];
    }
    
    NSString *description =
    [NSString stringWithFormat:@"[%@] %@", hy_getMethodString(sel), message];
    
    NSArray<NSString *> *callStackSymbols = [NSThread callStackSymbols];
    NSString *location = getLocation(callStackSymbols);
    
    NSArray<HyCrashHandler*> *crashHanders = HyCrashHookManager.manager.crashHanders;
    [crashHanders enumerateObjectsUsingBlock:^(HyCrashHandler * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.block) {
            if (isObjectClass) {
                if ([obj.classes containsObject:NSObject.class]) {
                    obj.block(cls, location, description, callStackSymbols);
                }
            } else {
                if ([obj.classes containsObject:cls]) {
                    obj.block(cls, location, description, callStackSymbols);
                }
            }
        }
    }];
   
#ifdef DEBUG
    if (HyCrashHookManager.manager.isOpenLog) {
         NSLog(@"\n=============================== CrashHook Start ===============================\n-------------------- CrashClass  --------------------\n%@\n-------------------- Location    --------------------\n%@\n-------------------- Description --------------------\n%@\n-------------------- CallStack   --------------------\n%@\n=============================== CrashHook End   ===============================\n.\n.\n.",NSStringFromClass(cls), location, description, callStackSymbols);
    }
#endif
}

