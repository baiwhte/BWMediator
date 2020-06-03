//
//  AppDelegate.m
//  BWMediator Example
//
//  Created by baiwhte on 2020/6/1.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import "AppDelegate.h"
#import <BWMediator/BWScheduler.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [BWScheduler performSelectorByPriority:900 selector:@selector(application:didFinishLaunchingWithOptions:), application, launchOptions];
    return YES;
}



@end
