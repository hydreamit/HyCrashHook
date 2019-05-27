//
//  NSNotificationCenter_CrashHookTestController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/17.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "NSNotificationCenter_CrashHookTestController.h"
#import "HyCrashHookManager.h"
#import "HyCrashHookMethods.h"


@interface NSNotificationCenter_CrashHookTestController ()
@property (nonatomic,strong) id observer;
@end


@implementation NSNotificationCenter_CrashHookTestController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(testNote:)
                                                 name:@"testNote"
                                               object:nil];
    
    self.observer =
    [[NSNotificationCenter defaultCenter] addObserverForName:@"testNoteBlock"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      
         // have retain cycle, has hooked set nil
         NSLog(@"testNoteBlock:%@", self);
    }];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"postNotification" forState:UIControlStateNormal];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // must be remove observer if usingBlock
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (void)buttonAction {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNote" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNoteBlock" object:nil];
}

- (void)testNote:(NSNotification *)note {
    
    NSLog(@"%@", note.name);
}

- (void)dealloc {
    
    NSLog(@"dealloc:%@", self);
//  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
