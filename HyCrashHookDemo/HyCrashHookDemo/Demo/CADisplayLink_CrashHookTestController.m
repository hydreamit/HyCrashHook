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
    HyCrashHandler *crashHandler =
    [HyCrashHookManager subscribeCrashWithClasses:@[CADisplayLink.class] 
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
