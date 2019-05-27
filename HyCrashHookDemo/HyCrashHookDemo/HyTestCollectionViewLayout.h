//
//  HyTestCollectionViewLayout.h
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/19.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyTestCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic,strong) NSArray<Class> *defaultClasses;

@end

NS_ASSUME_NONNULL_END
