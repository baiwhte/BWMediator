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
    
    
    NSDictionary *tabBarItemtitleColor = [NSDictionary dictionaryWithObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
    UIViewController *homeViewController = [BWScheduler performWithProtocol:@protocol(BWHomepageModuleService) selector:@selector(homeViewController)];
    homeViewController.navigationItem.title = @"首页";
    homeViewController.tabBarItem.title = @"首页";
    homeViewController.tabBarItem.image = [[UIImage imageNamed:@"tab_home_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_home_h_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [homeViewController.tabBarItem setTitleTextAttributes:tabBarItemtitleColor forState:UIControlStateSelected];
    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:homeViewController]];

    UIViewController *loginViewController = [BWScheduler performWithProtocol:@protocol(BWAccountModuleService) selector:@selector(loginViewController)];
    //    vc5.navigationItem.title = @"我的";
    loginViewController.tabBarItem.title = @"我的";
    loginViewController.tabBarItem.image = [[UIImage imageNamed:@"tab_profile_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    loginViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_profile_h_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [loginViewController.tabBarItem setTitleTextAttributes:tabBarItemtitleColor forState:UIControlStateSelected];
    [self addChildViewController:[[UINavigationController alloc] initWithRootViewController:loginViewController]];
}

@end
