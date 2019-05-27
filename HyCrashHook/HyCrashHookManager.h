//
//  HyCrashHookManager.h
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/15.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void(^HyCrashHandlerBlock)(Class cls,                        // Crash class
                                   NSString *location,              // method Location
                                   NSString *description,          // description
                                   NSArray<NSString *> *callStack // callStack
                                   );

NS_ASSUME_NONNULL_BEGIN

@interface HyCrashHandler : NSObject
@property (nonatomic,copy,readonly) HyCrashHandlerBlock block;
@property (nonatomic,strong,readonly) NSArray<Class> *classes;
@end
@interface HyCrashHookManager : NSObject
@property (nonatomic,strong,readonly) NSMutableArray <HyCrashHandler*> *crashHanders;
@property (nonatomic,strong,readonly) NSArray<Class> *defaultClasses;
@property (nonatomic,assign,readonly,getter=isOpenLog) BOOL openLog;
+ (instancetype)manager;

/**
 Open CrashHook

 @param classes :
 @[
 NSObject.class,
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
 NSData.class
 ]
 */
+ (void)openCrashHookWithClasses:(NSArray<Class> * _Nullable)classes;


/**
 subscribe Crash

 @param classes subscribe Class
 @param block subscribe callback
 @return HyCrashHandler
 */
+ (HyCrashHandler *)subscribeCrashWithClasses:(NSArray<Class> * _Nullable)classes
                                        block:(_Nullable HyCrashHandlerBlock)block;


/**
 dispose Crash Subscribe

 @param crashHander crashHander
 */
+ (void)disposeCrashHander:(HyCrashHandler *)crashHander;


/**
 open CrashHookLog
 */
+ (void)openCrashHookLog;


/**
 close CrashHookLog
 */
+ (void)closeCrashHookLog;

@end

NS_ASSUME_NONNULL_END
