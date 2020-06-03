//
//  NSInvocation+Mediator.h
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (Mediator)

- (void)bw_setArgument:(id)object atIndex:(NSUInteger)index;

- (nullable id)bw_returnValue;


- (void)bw_setArgumentWithArgs:(va_list)arguments retainedArguments:(NSMutableArray *)retainedArguments;

@end

NS_ASSUME_NONNULL_END
