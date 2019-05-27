//
//  HyTestViewController.m
//  HyCrashHook
//  https://github.com/hydreamit/HyCrashHook
//
//  Created by huangyi on 2019/5/10.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "HyCrashHookManager.h"
#import "HyTestViewController.h"
#import "HyTestCollectionViewCell.h"
#import "HyTestCollectionViewLayout.h"
#import "HyCrashHookMethods.h"


@interface HyTestViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic,strong) NSArray *defaultClasses;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UITextField *textf;
@end


@implementation HyTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"CrashHookDemo";
    self.defaultClasses = HyCrashHookManager.manager.defaultClasses;
    [self.view addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return self.defaultClasses.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return
    [HyTestCollectionViewCell cellWithColletionView:collectionView
                                          indexPath:indexPath
                                          hookClass:self.defaultClasses[indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *vcClassString =
    [NSString stringWithFormat:@"%@_CrashHookTestController", self.defaultClasses[indexPath.row]];
    UIViewController *vc = [NSClassFromString(vcClassString) new];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.navigationItem.title = NSStringFromClass(self.defaultClasses[indexPath.row]);
    [self.navigationController pushViewController:vc animated:YES];
}

- (UICollectionView *)collectionView {
    if (!_collectionView){
        
        HyTestCollectionViewLayout *layout = [HyTestCollectionViewLayout new];
        layout.defaultClasses = self.defaultClasses;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:HyTestCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(HyTestCollectionViewCell.class)];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;        
    }
    return _collectionView;
}

@end
