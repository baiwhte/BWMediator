//
//  BWTabBarProtocolImpl.m
//  TabBarController
//
//  Created by baiwhte on 2020/6/2.
//  Copyright © 2020 baiwhte.inc. All rights reserved.
//

#import "BWTabBarProtocolImpl.h"

#import "BWTabBarController.h"

@implementation BWTabBarProtocolImpl

BW_KeyValue_EXPORT(@"BWTabBarModuleService", @"BWTabBarProtocolImpl", 0)

+ (NSUInteger)priority; {
    return BWModulePriorityRequired;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    NSLog(@"ModulesImpl:%@", NSStringFromClass(self.class));
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    BWTabBarController *tabBarController = [[BWTabBarController alloc] init];

    
    window.rootViewController = tabBarController;
    window.backgroundColor = [UIColor whiteColor];
    [window makeKeyAndVisible];
    
    UIApplication.sharedApplication.delegate.window = window;
        
    return YES;
}



@end
