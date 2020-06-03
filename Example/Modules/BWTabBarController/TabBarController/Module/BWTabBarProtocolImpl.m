//
//  BWTabBarProtocolImpl.m
//  TabBarController
//
//  Created by CHENXIUWU699 on 2020/6/2.
//  Copyright © 2020 pingan.inc. All rights reserved.
//

#import "BWTabBarProtocolImpl.h"
#import <BWMediator/BWScheduler.h>

#import "BWHomepageModuleService.h"
#import "BWAccountModuleService.h"

#import "BWTabBarController.h"

@implementation BWTabBarProtocolImpl

//BW_KeyValue_EXPORT(@"BWTabBarModuleService", @"BWTabBarProtocolImpl", 0)

+ (NSUInteger)priority; {
    return BWModulePriorityRequired;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    NSLog(@"ModulesImpl:%@", NSStringFromClass(self.class));
//    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//
//    NSDictionary *tabBarItemtitleColor = [NSDictionary dictionaryWithObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
//    UIViewController *homeViewController = [BWScheduler performWithProtocol:@protocol(BWHomepageModuleService) selector:@selector(homeViewController)];
//    homeViewController.navigationItem.title = @"首页";
//    homeViewController.tabBarItem.title = @"首页";
//    homeViewController.tabBarItem.image = [[UIImage imageNamed:@"tab_home_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    homeViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_home_h_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [homeViewController.tabBarItem setTitleTextAttributes:tabBarItemtitleColor forState:UIControlStateSelected];
//
//
//    UIViewController *loginViewController = [BWScheduler performWithProtocol:@protocol(BWAccountModuleService) selector:@selector(loginViewController)];
//    //    vc5.navigationItem.title = @"我的";
//    loginViewController.tabBarItem.title = @"我的";
//    loginViewController.tabBarItem.image = [[UIImage imageNamed:@"tab_profile_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    loginViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_profile_h_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [loginViewController.tabBarItem setTitleTextAttributes:tabBarItemtitleColor forState:UIControlStateSelected];
//
//    BWTabBarController *tabBarController
//    = [[BWTabBarController alloc] initWithViewControllers:@[
//        [[UINavigationController alloc] initWithRootViewController:homeViewController],
//        [[UINavigationController alloc] initWithRootViewController:loginViewController]
//    ]];
//
//    tabBarController.tabBar.translucent = NO;
//    window.rootViewController = tabBarController;
//    window.backgroundColor = [UIColor whiteColor];
//    [window makeKeyAndVisible];
    
    NSLog(@"delegate:%@", UIApplication.sharedApplication.delegate);
        
    return YES;
}



@end
