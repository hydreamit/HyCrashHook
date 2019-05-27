//
//  CADisplayLink_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/23.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "CADisplayLink_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@interface CADisplayLink_CrashHookTestController ()
@property (nonatomic,strong) CADisplayLink *link;
@end


@implementation CADisplayLink_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[CADisplayLink.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {
        
        NSLog(@"subscribeCrash: Class:%@", cls);
    }];
    
    hy_swizzleDealloc(self, ^(id instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    
    // retain cycle
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkTest)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)linkTest {

    NSLog(@"link+++++++");
}

//- (void)dealloc {

//    [self.link invalidate];
//}

@end
