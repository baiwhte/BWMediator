//
//  BWMediatorManager.h
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BWMediatorManager : NSObject

@property (nonatomic, strong, readonly) NSArray<NSString *> *sortedModules;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

+ (BWMediatorManager *)manager;

- (nullable id)invokeWithProtocol:(Protocol *)protocol
                         selector:(SEL)selector
                        arguments:(va_list)argList;

- (nullable id)invokeWithProtocol:(Protocol *)protocol
                         priority:(NSInteger)priority
                         selector:(SEL)selector
                        arguments:(va_list)argList;

- (NSObject *)objectWithProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
