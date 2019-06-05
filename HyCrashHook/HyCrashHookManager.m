//
//  HyCrashHookManager.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookManager.h"


@interface HyCrashHandler ()
@property (nonatomic,copy) HyCrashHandlerBlock block;
@property (nonatomic,strong) NSArray<Class> *classes;
@end
@implementation HyCrashHandler
+ (HyCrashHandler *)handerWithWithClasses:(NSArray<Class> * _Nullable)classes
                                    block:(_Nullable HyCrashHandlerBlock)block {
    
    HyCrashHandler *hander = [[self alloc] init];
    hander.classes = classes;
    hander.block = [block copy];
    return hander;
}

- (void)dispose {
    self.block = nil;
}

- (void)dealloc {
    self.block = nil;
}
@end


@interface HyCrashHookManager () <NSCopying, NSMutableCopying>
@property (nonatomic,strong) NSArray<Class> *defaultClasses;
@property (nonatomic,strong) NSMutableArray<Class> *openedClasses;
@property (nonatomic,strong) NSMutableArray <HyCrashHandler*> *crashHandlers;
@property (nonatomic,assign,getter=isOpenLog) BOOL openLog;
@end

@implementation HyCrashHookManager

+ (instancetype)manager {
    
    static HyCrashHookManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[super allocWithZone:NULL] init];
        _instance.openLog = YES;
        _instance.crashHandlers = @[].mutableCopy;
        _instance.openedClasses = @[].mutableCopy;
        _instance.defaultClasses = @[NSObject.class,
                                     NSArray.class, NSMutableArray.class,
                                     NSDictionary.class, NSMutableDictionary.class,
                                     NSString.class, NSMutableString.class,
                                     NSAttributedString.class, NSMutableAttributedString.class,
                                     NSSet.class, NSMutableSet.class,
                                     NSOrderedSet.class, NSMutableOrderedSet.class,
                                     NSNotificationCenter.class,
                                     NSDecimalNumber.class,
                                     NSUserDefaults.class,
                                     CADisplayLink.class,
                                     NSTimer.class,
                                     NSCache.class,
                                     NSData.class];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self manager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

+ (void)openCrashHookWithClasses:(NSArray<Class> * _Nullable)classes {
    
    HyCrashHookManager *manager = [self manager];
    
    NSArray *clsArray = classes ?: manager.defaultClasses;
    NSMutableArray *filterArray = @[].mutableCopy;
    if (clsArray) {
        [clsArray enumerateObjectsUsingBlock:^(Class cls, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![manager.openedClasses containsObject:cls] &&
                [manager.defaultClasses containsObject:cls]) {
                [filterArray addObject:cls];
            }
        }];
    }
    [filterArray makeObjectsPerformSelector:NSSelectorFromString(@"hy_openCrashHook")];
    [manager.openedClasses addObjectsFromArray:filterArray];
}

+ (HyCrashHandler *)subscribeCrashWithClasses:(NSArray<Class> * _Nullable)classes
                                        block:(_Nullable HyCrashHandlerBlock)block {
    
    NSMutableArray *filterArray = @[].mutableCopy;
    if (classes) {
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[self manager] defaultClasses] containsObject:obj]) {
                [filterArray addObject:obj];
            }
        }];
    } else {
        filterArray = [[self manager] defaultClasses].copy;
    }
    
    if (filterArray.count) {
        HyCrashHandler *hander = [HyCrashHandler handerWithWithClasses:filterArray block:block];
        [[[self manager] crashHandlers] addObject:hander];
        return hander;
    } else {
        return nil;
    }
}

+ (void)disposeCrashHandler:(HyCrashHandler *)crashHandler {
    
    if (crashHandler &&
        [[[self manager] crashHandlers] containsObject:crashHandler]) {
        
        [crashHandler dispose];
        [[[self manager] crashHandlers] removeObject:crashHandler];
    }
}

+ (void)openCrashHookLog {
    [[self manager] setOpenLog:YES];
}

+ (void)closeCrashHookLog {
    [[self manager] setOpenLog:NO];
}

@end
