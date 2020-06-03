//
//  BWTabBarController.m
//  TabBarController
//
//  Created by CHENXIUWU699 on 2020/6/2.
//  Copyright © 2020 pingan.inc. All rights reserved.
//

#import "BWTabBarController.h"

#import <BWMediator/BWScheduler.h>
#import "BWHomepageModuleService.h"
#import "BWAccountModuleService.h"

@implementation BWTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSDictionary *tabBarItemtitleColor = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    UIViewController *homeViewController = [BWScheduler performWithProtocol:@protocol(BWHomepageModuleService) selector:@selector(homeViewController)];
    homeViewController.navigationItem.title = @"首页";
    homeViewController.tabBarItem.title = @"首页";
    homeViewController.tabBarItem.image = [[UIImage imageNamed:@"tab_home_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_home_h_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [homeViewController.tabBarItem setTitleTextAttributes:tabBarItemtitleColor forState:UIControlStateSelected];

    UIViewController *loginViewController = [BWScheduler performWithProtocol:@protocol(BWAccountModuleService) selector:@selector(loginViewController)];
    loginViewController.navigationItem.title = @"我的";
    loginViewController.tabBarItem.title = @"我的";
    loginViewController.tabBarItem.image = [[UIImage imageNamed:@"tab_profile_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    loginViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_profile_h_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [loginViewController.tabBarItem setTitleTextAttributes:tabBarItemtitleColor forState:UIControlStateSelected];
    
    self.viewControllers = @[
        [[UINavigationController alloc] initWithRootViewController:homeViewController],
        [[UINavigationController alloc] initWithRootViewController:loginViewController]
    ];
    
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = UIColor.whiteColor;
    self.tabBar.tintColor = UIColor.redColor;
}

@end
