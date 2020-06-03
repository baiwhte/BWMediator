//
//  BWHomepageService.h
//  ModuleService
//
//  Created by baiwhte on 2020/6/2.
//  Copyright © 2020 baiwhte.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BWMediator/BWMediatorProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BWHomepageModuleService <BWMediatorProtocol>

- (UIViewController *)homeViewController;


- (void)test:(long)ll;

@end

NS_ASSUME_NONNULL_END
