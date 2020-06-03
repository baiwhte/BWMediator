//
//  BWAccountProtocolImpl.m
//  Account
//
//  Created by baiwhte on 2020/6/2.
//  Copyright © 2020 baiwhte.inc. All rights reserved.
//

#import "BWAccountProtocolImpl.h"

#import "BWLoginViewController.h"

@implementation BWAccountProtocolImpl

BW_KeyValue_EXPORT(@"BWAccountModuleService", @"BWAccountProtocolImpl", 0)

- (UIViewController *)loginViewController;
{
    return [[BWLoginViewController alloc] init];
}

+ (NSUInteger)priority; {
    return 980;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
