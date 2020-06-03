//
//  SCHomepageProtocolImpl.m
//  Homepage
//
//  Created by 陈修武 on 2019/12/10.
//  Copyright © 2019 pingan.inc. All rights reserved.
//

#import "BWHomepageProtocolImpl.h"
#import <UIKit/UIKit.h>

@implementation BWHomepageProtocolImpl

//SCM_EXPORT_MODULE()
SCM_STRINGS_EXPORT(@"BWHomepageService", @"SCHomepageProtocolImpl", 0)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"ModulesImpl:%@", NSStringFromClass(self.class));
    return YES;
}

+ (NSUInteger)priority; {
    return 900;
}

@end
