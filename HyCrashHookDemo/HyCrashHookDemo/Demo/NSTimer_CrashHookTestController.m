//
//  NSTimer_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/23.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSTimer_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@interface NSTimer_CrashHookTestController ()
@property (nonatomic,strong) NSTimer *timer1;
@property (nonatomic,strong) NSTimer *timer2;
@property (nonatomic,strong) NSTimer *timer3;
@end


@implementation NSTimer_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribe hooked crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSTimer.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {

        NSLog(@"subscribeCrash: Class:%@", cls);
    }];

    hy_swizzleDealloc(self, ^(id instance) {

        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    // retain cycle
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer1Test) userInfo:@1 repeats:YES];

    self.timer2 =
    [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timer2Test) userInfo:@1 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer2 forMode:NSRunLoopCommonModes];
    [self.timer2 fire];
}

- (void)timer1Test {
    
    NSLog(@"timer1+++++");
}

- (void)timer2Test {
    
    NSLog(@"timer2-----");
}

//- (void)dealloc {
//
//    [self.timer1 invalidate];
//    [self.timer2 invalidate];
//}

@end
