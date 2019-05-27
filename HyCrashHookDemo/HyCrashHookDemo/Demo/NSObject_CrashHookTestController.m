//
//  NSObject_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSObject_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@interface KVOTestObject : UIViewController
@property (nonatomic,copy) NSString *string;
@end
@implementation KVOTestObject
@end




@interface NSObject_CrashHookTestController ()
@property (nonatomic,strong) KVOTestObject *kvoTestObject;
@end


@implementation NSObject_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSObject.class] block:^(__unsafe_unretained Class cls, NSString *location, NSString *description, NSArray<NSString *> *callStack) {

        NSLog(@"");
    }];
    
    hy_swizzleDealloc(self, ^(NSObject_CrashHookTestController *instance) {
        
        NSLog(@"hy_swizzleDealloc:%@", NSStringFromClass([instance class]));
        [HyCrashHookManager disposeCrashHander:crashHander];
    });
    
    [self test_kvc];
    [self test_kvo];
    [self test_unrecognizedSelector];
}

- (void)test_unrecognizedSelector {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"unrecognizedSelector" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = UIColor.orangeColor;
    button.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    [button sizeToFit];
    button.center = CGPointMake(self.view.bounds.size.width / 2,
                                self.view.bounds.size.height / 2);
    [self.view addSubview:button];
   
    [button addTarget:self
               action:sel_registerName("buttonAction")
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)test_kvc {
    
    NSObject *object = [[NSObject alloc] init];
    [object setValue:@"123" forKey:@"haha"];
    [object setValue:@"123" forKeyPath:@"haha"];
    [object valueForKey:@"haha"];
    [object valueForKeyPath:@"haha"];
}

- (void)test_kvo {
    
    self.kvoTestObject = [[KVOTestObject alloc] init];

    [self.kvoTestObject addObserver:self
                         forKeyPath:@"string"
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:@"1"];

    [self.kvoTestObject addObserver:self
                         forKeyPath:@"string"
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:nil];

    [self.kvoTestObject addObserver:self
                         forKeyPath:@"string"
                            options:NSKeyValueObservingOptionNew
                            context:@"1"];

    [self.kvoTestObject addObserver:self
                         forKeyPath:@"string"
                            options:NSKeyValueObservingOptionNew
                            context:@"123"];


     // it is not registered as an observer.'
    [self.kvoTestObject removeObserver:self forKeyPath:@"345"];
    // it is not registered as an observer.'
    [self.kvoTestObject removeObserver:self forKeyPath:@"string" context:@"345"];

    // success
    [self.kvoTestObject removeObserver:self forKeyPath:@"string" context:@"123"];

    // it is not registered as an observer.'
    [self.kvoTestObject removeObserver:self forKeyPath:@"string" context:@"123"];
    [self.kvoTestObject removeObserver:self forKeyPath:@"string" context:@"123"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       
                self.kvoTestObject.string = @"kvo_test";
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {

    NSLog(@"object:%@, keyPath:%@, change:%@, context:%@", object, keyPath, change, context);
}

@end
