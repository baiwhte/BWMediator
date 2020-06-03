//
//  BWAccountModuleService.h
//  ModuleService
//
//  Created by CHENXIUWU699 on 2020/6/2.
//  Copyright © 2020 pingan.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BWMediator/BWMediatorProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BWAccountModuleService <BWMediatorProtocol>

- (UIViewController *)loginViewController;

@end

NS_ASSUME_NONNULL_END
