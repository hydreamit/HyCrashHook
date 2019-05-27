//
//  NSString_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSString_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSString_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSString.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    [self test_checkHas];
    [self test_appending];
    [self test_substring];
    [self test_replacing];
}

/*
 @"hasPrefix:",
 @"hasSuffix:",
 */
- (void)test_checkHas {
    
    NSString *string = [NSString stringWithFormat:@"12345"];
    BOOL prefix = [string hasPrefix:[self nilObject]];
    BOOL suffix = [string hasSuffix:[self nilObject]];
    NSLog(@"prefix:%d, suffix:%d", prefix, suffix);
}

/*
 @"stringByAppendingString:",
 @"stringByAppendingFormat:",
 */
- (void)test_appending {
    
    NSString *string = [NSString stringWithFormat:@"12345"];
    [string stringByAppendingString:[self nilObject]];
//    [string stringByAppendingFormat:[self nilObject]];
}

/*
 @"substringFromIndex:",
 @"substringToIndex:",
 @"substringWithRange:",
 @"rangeOfString:options:range:locale:",
 */
- (void)test_substring {
    
    NSString *string = [NSString stringWithFormat:@"12345"];
    NSString *stringOne = [string substringFromIndex:6];
    NSString *stringTwo = [string substringToIndex:6];
    NSString *stringThree = [string substringWithRange:NSMakeRange(3, 6)];
    NSRange rangeOne = [string rangeOfString:[self nilObject]];
    NSRange rangeTwo = [string rangeOfString:@"123" options:NSCaseInsensitiveSearch range:NSMakeRange(3, 6)];
    NSLog(@"stringOne:%@,stringTwo:%@,stringThree:%@,rangeOne:%@,rangeTwo:%@,", stringOne, stringTwo, stringThree, NSStringFromRange(rangeOne), NSStringFromRange(rangeTwo));
}

/*
 @"stringByReplacingCharactersInRange:withString:",
 @"stringByReplacingOccurrencesOfString:withString:"
 @"stringByReplacingOccurrencesOfString:withString:options:range:",
 */
- (void)test_replacing {
    
    NSString *string = [NSString stringWithFormat:@"12345"];
    NSString *stringOne = [string stringByReplacingOccurrencesOfString:[self nilObject] withString:@"6"];
    NSString *stringTwo = [string stringByReplacingOccurrencesOfString:@"5" withString:[self nilObject]];
    NSString *stringThree = [string stringByReplacingOccurrencesOfString:@"5" withString:@"6" options:NSCaseInsensitiveSearch range:NSMakeRange(3, 6)];
    NSString *stringFour = [string stringByReplacingCharactersInRange:NSMakeRange(3, 6) withString:@"6"];
    NSString *stringFive = [string stringByReplacingCharactersInRange:NSMakeRange(3, 5) withString:[self nilObject]];
    NSLog(@"stringOne:%@,stringTwo:%@,stringThree:%@,stringFour:%@,stringFive:%@,", stringOne, stringTwo, stringThree, stringFour, stringFive);
}

- (id)nilObject {
    return nil;
}

@end
