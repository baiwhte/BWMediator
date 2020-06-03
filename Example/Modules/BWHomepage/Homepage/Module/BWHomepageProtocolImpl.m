//
//  SCHomepageProtocolImpl.m
//  Homepage
//
//  Created by baiwhte on 2019/12/10.
//  Copyright © 2019 baiwhte.inc. All rights reserved.
//

#import "BWHomepageProtocolImpl.h"
#import "SCHomepageViewController.h"

@implementation BWHomepageProtocolImpl

BW_KeyValue_EXPORT(@"BWHomepageModuleService", @"BWHomepageProtocolImpl", 0)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"ModulesImpl:%@", NSStringFromClass(self.class));
    return YES;
}

+ (NSUInteger)priority; {
    return 990;
}

- (UIViewController *)homeViewController {
    return [[SCHomepageViewController alloc] init];
}

- (void)test:(long)ll; {
    NSLog(@"test: %ld, %@", ll, NSThread.currentThread);
}



- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
