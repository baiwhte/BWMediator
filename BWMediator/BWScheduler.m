//
//  BWScheduler.m
//  BWMediator
//
//  Created by CHENXIUWU699 on 2020/6/1.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import "BWScheduler.h"
#import "BWMediatorProtocol.h"
#import "BWMediatorManager.h"

#import <objc/runtime.h>

@implementation BWScheduler

+ (id)performWithProtocol:(Protocol*)protocol selector:(SEL)selector, ...;
{
    NSAssert(protocol, @"protocol must not be nil");
    NSAssert(protocol_conformsToProtocol(protocol, NSProtocolFromString(@"BWMediatorProtocol")) ,
             @"protocol must be conforms BWMediatorProtocol");
    id returnObj;
    va_list args;
    va_start(args, selector);
    returnObj = [BWMediatorManager.manager invokeWithProtocol:protocol
                                                      selector:selector
                                                     arguments:args];
    va_end(args);
    return returnObj;
}
    
+ (BOOL)performSelectorInAllModules:(SEL)selector, ...;
{
    BWMediatorManager *manager = BWMediatorManager.manager;
    for (NSString *protocolKey in manager.sortedModules) {
        va_list args;
        va_start(args, selector);
        [manager invokeWithProtocol:NSProtocolFromString(protocolKey)
                           priority:BWModulePriorityRequired
                           selector:selector
                          arguments:args];
        va_end(args);
    }
    return YES;
}

+ (BOOL)performSelectorByPriority:(NSInteger)priority selector:(SEL)selector, ...; {
    BWMediatorManager *manager = BWMediatorManager.manager;
    for (NSString *protocolKey in manager.sortedModules) {
        va_list args;
        va_start(args, selector);
        [manager
         invokeWithProtocol:NSProtocolFromString(protocolKey)
         priority:priority
         selector:selector
         arguments:args];
        va_end(args);
    }
    return YES;
}
    
+ (id<BWMediatorProtocol>)moduleByProtocol:(Protocol *)serviceProtocol; {
    NSAssert(serviceProtocol, @"protocol must not be nil");
    NSAssert(protocol_conformsToProtocol(serviceProtocol,
                                         NSProtocolFromString(@"BWMediatorProtocol")) ,
             @"protocol must be conforms BWMediatorProtocol");
    return (id<BWMediatorProtocol>)[BWMediatorManager.manager objectWithProtocol:serviceProtocol];
}

@end
