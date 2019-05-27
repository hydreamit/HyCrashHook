//
//  Layout.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/19.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyTestCollectionViewLayout.h"


@interface HyTestCollectionViewLayout ()
@property (nonatomic,strong) NSMutableArray *attrs;
@property (nonatomic,assign) CGFloat heigth;
@end


@implementation HyTestCollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.attrs = [NSMutableArray array];
    self.minimumLineSpacing = 5;
    self.minimumInteritemSpacing = 5;
    self.sectionInset = UIEdgeInsetsMake(10,  10, 10, 10);
    CGFloat itemW = (self.collectionView.frame.size.width -
                     self.sectionInset.left -
                     self.sectionInset.right  -
                     self.minimumLineSpacing);
    
    NSInteger itemCount = self.defaultClasses.count;
    for (NSInteger i = 0; i < itemCount; i++) {
        
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attr =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexpath];
        
        CGFloat item_x = self.sectionInset.left;
        CGFloat item_y = self.heigth + self.sectionInset.top;
        CGFloat item_w = itemW;
        CGFloat item_h = 45;
        
        Class currentClass = self.defaultClasses[i];
        
        Class lastClass;
        if (i > 0) {
            lastClass = self.defaultClasses[i - 1];
        }
        
        Class nextClass;
        if (i != itemCount - 1) {
            nextClass = self.defaultClasses[i + 1];
        }
        
        if (i == 0) {
            
            if ([self isMutableClass:nextClass]) {
                item_w = (itemW - self.minimumLineSpacing) / 2;
            } else {
                self.heigth = item_y + item_h;
            }
            
        } else if (i == itemCount - 1) {
            
            if ([self isMutableClass:currentClass]) {
                item_w = (itemW - self.minimumLineSpacing) / 2;
            } else {
                self.heigth = item_y + item_h;
            }
            
        } else {
            
            if (![self isMutableClass:currentClass] &&
                [self isMutableClass:nextClass]) {
                
                item_w = (itemW - self.minimumLineSpacing) / 2;
                
            } else if ([self isMutableClass:currentClass] &&
                       ![self isMutableClass:lastClass]) {
                
                item_w = (itemW - self.minimumLineSpacing) / 2;
                item_x += (item_w + self.minimumInteritemSpacing);
                self.heigth = item_y + item_h;
                
            } else {
                
                self.heigth = item_y + item_h;
            }
        }

        attr.frame = CGRectMake(item_x, item_y, item_w, item_h);
        [self.attrs addObject:attr];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrs;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(0, self.heigth + self.sectionInset.bottom - self.minimumLineSpacing + self.sectionInset.top);
}

- (BOOL)isMutableClass:(Class)cls {
    return [NSStringFromClass(cls) hasPrefix:@"NSMutable"];
}

@end
