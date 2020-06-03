//
//  BWTabBarController.m
//  TabBarController
//
//  Created by CHENXIUWU699 on 2020/6/2.
//  Copyright © 2020 pingan.inc. All rights reserved.
//

#import "BWTabBarController.h"

@implementation BWTabBarController

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers{
    if (self = [super init]) {
        [self buildChildControllers:viewControllers];
    }
    return self;
}

- (void)buildChildControllers:(NSArray<UIViewController *>*)viewControllers{
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self addChildViewController:obj];
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

@end
