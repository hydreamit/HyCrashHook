//
//  NSAttributedString_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/19.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSAttributedString_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSAttributedString_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSAttributedString.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    
    NSString *nilString = nil;
    
    NSAttributedString *attrOne = [[NSAttributedString alloc] initWithString:nilString];
    NSLog(@"attrOne:%@", attrOne);

    NSAttributedString *attrTwo = [[NSAttributedString alloc] initWithString:nilString attributes:nil];
    NSLog(@"attrTwo:%@", attrTwo);
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"12345"];
    
    NSAttributedString *attrThree = [attr attributedSubstringFromRange:NSMakeRange(3, 6)];
    NSLog(@"attrThree:%@", attrThree);
    
    [attr enumerateAttribute:@"test"
                     inRange:NSMakeRange(3, 6)
                     options:NSAttributedStringEnumerationReverse
                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                       NSLog(@"value:%@", value);
                  }];
}

@end
