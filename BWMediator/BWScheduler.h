//
//  BWScheduler.h
//  BWMediator
//
//  Created by CHENXIUWU699 on 2020/6/1.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BWMediatorProtocol;

#define BWSchedulerModule(service_protocol) ((id<service_protocol>)[BWScheduler moduleByService:@protocol(service_protocol)])

#define BWSafeObject(ARG) (ARG) ?: BWMediatorNil.mediatorNil

@interface BWScheduler : NSObject

+ (nullable id<BWMediatorProtocol>)moduleByProtocol:(Protocol *)serviceProtocol;

+ (nullable id)performWithProtocol:(Protocol *)protocol selector:(SEL)selector, ...;


+ (BOOL)performSelectorInAllModules:(SEL)selector, ...;
+ (BOOL)performSelectorByPriority:(NSInteger)priority selector:(SEL)secector, ...;

@end

NS_ASSUME_NONNULL_END
