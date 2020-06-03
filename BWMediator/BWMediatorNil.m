//
//  BWNull.m
//  BWMediator
//
//  Created by CHENXIUWU699 on 2020/6/1.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import "BWMediatorNil.h"

@implementation BWMediatorNil

+ (BWMediatorNil *)mediatorNil {
    static dispatch_once_t onceToken;
    static BWMediatorNil *mediatorNil = nil;
    dispatch_once(&onceToken, ^{
        mediatorNil = [[self alloc] init];
    });
    
    return mediatorNil;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    // Always return the singleton.
    return self.class.mediatorNil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}

@end
