# HyCrashHook


Hook 常见Crash不让程序闪退， 订阅Crash根据自身需要做相应处理。

****

|Class|
|:---:|
|NSObject (KVC、KVO、UnrecognizedSelector)|
|:---:|
|NSArray|NSMutableArray|
|:---:|:---:|
|NSDictionary|NSMutableDictionary|
|:---:|:---:|
|NSStringNSMutableString|
|:---:|:---:|
|NSAttributedString|NSMutableAttributedString|
|:---:|:---:|
|NSSet|NSMutableSet|
|:---:|:---:|
|NSOrderedSet|NSMutableOrderedSet|
|:---:|:---:|
|NSNotificationCenter|
|:---:|
|NSDecimalNumber|
|:---:|
|NSUserDefaults|
|:---:|
|CADisplayLink|
|:---:|
|NSTimer|
|:---:|
|NSCache|
|:---:|
|NSData|

****

## 如何导入

__Podfile__

```
pod 'HyCrashHook'
```

__手动导入__

  直接将`HyCrashHook`文件夹拖入项目，然后把`NSMutableArray+CrashHook.m`文件的编译选项添加-fno-objc-arc



## 如何使用

* 开启需要Hook的类

```objc

    // 开启Hook所有支持的类
    [HyCrashHookManager openCrashHookWithClasses:nil];
    
    // 开启Hook指定的类
    [HyCrashHookManager openCrashHookWithClasses:@[NSDictionary.class, NSMutableDictionary.class]];

```

* 订阅Hook类的Crash

```objc

    // 订阅所有已开启Hook类的Crash
    [HyCrashHookManager subscribeCrashWithClasses:nil
                                            block:^(__unsafe_unretained Class cls,
                                                    NSString *location,
                                                    NSString *description,
                                                    NSArray<NSString *> *callStack) {

         // handle hooked crash
        // ....
    }];
    
    // 订阅指定已开启Hook类的Crash
    HyCrashHandler *crashHander =
    [HyCrashHookManager subscribeCrashWithClasses:@[NSDictionary.class, NSMutableDictionary.class]
                                            block:^(__unsafe_unretained Class cls,
                                                    NSString *location,
                                                    NSString *description,
                                                    NSArray<NSString *> *callStack) {
    
         // handle hooked crash
        // ....
    }];
    
    // 取消某个订阅
    [HyCrashHookManager disposeCrashHander:crashHander];

```

* 开启关闭Crash日志打印

```objc

    // 开启Crash日志打印
    [HyCrashHookManager openCrashHookLog];


    // 关闭Crash日志打印
    [HyCrashHookManager closeCrashHookLog];

```

