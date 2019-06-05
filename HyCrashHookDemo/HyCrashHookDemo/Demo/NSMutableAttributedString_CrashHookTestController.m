//
//  NSMutableAttributedString_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/19.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSMutableAttributedString_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@implementation NSMutableAttributedString_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSAttributedString.class, NSMutableAttributedString.class] 
                                            block:^(Class  _Nullable __unsafe_unretained cls,
                                                    NSString * _Nullable location,
                                                    NSString * _Nullable description,
                                                    NSArray<NSString *> * _Nullable callStack) {
        
        NSLog(@"subscribeCrash Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHandler:crashHandler];
    });
    
    NSString *nilString = nil;
    
    NSMutableAttributedString *attrOne = [[NSMutableAttributedString alloc] initWithString:nilString];
    NSLog(@"attrOne:%@", attrOne);

    NSMutableAttributedString *attrTwo = [[NSMutableAttributedString alloc] initWithString:nilString attributes:nil];
    NSLog(@"attrTwo:%@", attrTwo);

    NSDictionary *nilDict = nil;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"12345"];
    NSLog(@"attr:%@", attr);
    
    [attr setAttributes:nilDict range:NSMakeRange(0, 6)];
    NSLog(@"attr:%@", attr);
    
    [attr addAttribute:NSFontAttributeName value:nilString range:NSMakeRange(0, 2)];
    NSLog(@"attr:%@", attr);
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 6)];
    NSLog(@"attr:%@", attr);

    [attr addAttributes:nilDict range:NSMakeRange(0, 3)];
    NSLog(@"attr:%@", attr);
    [attr addAttributes:@{} range:NSMakeRange(3, 6)];
    NSLog(@"attr:%@", attr);

    [attr removeAttribute:nilString range:NSMakeRange(0, 4)];
    NSLog(@"attr:%@", attr);
    [attr removeAttribute:NSFontAttributeName range:NSMakeRange(0, 5)];
    NSLog(@"attr:%@", attr);
    
    [attr deleteCharactersInRange:NSMakeRange(3, 6)];
    NSLog(@"attr:%@", attr);
    [attr replaceCharactersInRange:NSMakeRange(0, 1) withString:nilString];
    NSLog(@"attr:%@", attr);
    [attr replaceCharactersInRange:NSMakeRange(3, 4) withString:@"6"];
    NSLog(@"attr:%@", attr);
}

@end
