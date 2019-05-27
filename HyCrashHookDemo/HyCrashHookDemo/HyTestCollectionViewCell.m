//
//  HyTestCollectionViewCell.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/19.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyTestCollectionViewCell.h"


@interface HyTestCollectionViewCell ()
@property (nonatomic,strong) UILabel *hookClassLabel;
@end


@implementation HyTestCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.borderWidth = 1.0;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.contentView addSubview:self.hookClassLabel];
    }
    return  self;
}

+ (instancetype)cellWithColletionView:(UICollectionView *)collectionView
                            indexPath:(NSIndexPath *)indexPath
                            hookClass:(Class)hookClass {
    
    HyTestCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self)
                                              forIndexPath:indexPath];
    cell.hookClassLabel.text = NSStringFromClass(hookClass);
    if ([cell.hookClassLabel.text isEqualToString:@"NSObject"]) {
        cell.hookClassLabel.text = @"NSObject (KVC、KVO、UnrecognizedSelector)";
    }
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.hookClassLabel.frame = self.contentView.bounds;
}

- (UILabel *)hookClassLabel {
    if (!_hookClassLabel){
        _hookClassLabel = [[UILabel alloc] init];
        _hookClassLabel.textAlignment = NSTextAlignmentCenter;
        _hookClassLabel.textColor = [UIColor darkGrayColor];
        _hookClassLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    return _hookClassLabel;
}

@end
