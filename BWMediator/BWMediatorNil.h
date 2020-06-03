//
//  BWMediatorNull.h
//  BWMediator
//
//  Created by baiwhte on 2020/6/1.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BWMediatorNil : NSObject<NSCopying, NSCoding>

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

+ (BWMediatorNil *)mediatorNil;

@end

NS_ASSUME_NONNULL_END
