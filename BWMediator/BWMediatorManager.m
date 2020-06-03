//
//  BWMediatorManager.m
//  BWMediator
//
//  Created by CHENXIUWU699 on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import "BWMediatorManager.h"
#import "NSInvocation+Mediator.h"
#import "BWMediatorProtocol.h"

/// Objective-C call Swift's method should import namespace in framework
//#import <BWMediator/BWMediator-Swift.h>

/// Objective-C call Swift's method should import namespace in static library
#import "BWMediator-Swift.h"

NSDictionary<NSString*, Class>* BWGetAllModules(void);
NSString *const BWErrorDomain = @"BWMediator.Domain";

const NSInteger BWModuleInvokeError = 500;

@interface BWMediatorManager ()

@property (nonatomic, strong) Mediator *mediator;

@property (nonatomic, strong) dispatch_queue_t methodQueue;
//
@property (nonatomic, strong) NSDictionary *moduleClasses;
@property (nonatomic, strong) NSArray<NSString *> *sortedModules;

@end


@implementation BWMediatorManager

+ (BWMediatorManager *)manager {
    static dispatch_once_t onceToken;
    static BWMediatorManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.methodQueue   = dispatch_queue_create("com.bwmediator.method", DISPATCH_QUEUE_CONCURRENT);
        self.mediator      = Mediator.shared;
        self.moduleClasses = BWGetAllModules();
    }
    return self;
}

- (id)invokeWithProtocol:(Protocol *)protocol selector:(SEL)selector arguments:(va_list)argList; {
    return [self invokeWithProtocol:protocol priority:0 selector:selector arguments:argList];
}

- (id)invokeWithProtocol:(Protocol *)protocol priority:(NSInteger)priority selector:(SEL)selector arguments:(va_list)argList;
{
    NSString *protocolKey = NSStringFromProtocol(protocol);
    NSObject *target = [self objectWithProtocol:protocol];
    
    if ( nil == target || [target.class priority] < priority ) {
        return nil;
    }
    
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : [NSString stringWithFormat:@"未找到\"%@\"的实现类", protocolKey],
    };
    
    
    if (! [target respondsToSelector:selector]) {
        __weak id<BWMediatorProtocol> delegate = (id<BWMediatorProtocol>)target;
        if ([delegate respondsToSelector:@selector(errors:)]) {
            [delegate errors:[NSError errorWithDomain:BWErrorDomain
                                                 code:BWModuleInvokeError
                                             userInfo:userInfo]];
        }
        return nil;
    }
    
    return [self invokeWithTarget:target selector:selector arguments:argList];
}


- (NSObject *)objectWithProtocol:(Protocol *)protocol;
{
    NSObject *object = nil;
    NSString *protoName = NSStringFromProtocol(protocol);
    object = [self.mediator objectForKey:protoName index:0];
    if (object == nil) {
        Class cls = self.moduleClasses[protoName];
        if (cls == nil) {
            return object;
        }
        
        if ([cls respondsToSelector:@selector(sharedInstance)]) {
            object = [cls sharedInstance];
            NSObject *objCopy = [cls sharedInstance];
            if (objCopy != object) {
                object = nil;
            }
        }
        
        if (object == nil) {
            object = [[cls alloc] init];
            if (object) {
                [self.mediator appendWithObject:object forKey:protoName index:0];
            }
        }
    }
    return object;
}

- (id)invokeWithTarget:(id)target selector:(SEL)selector arguments:(va_list)argList;
{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    __weak id<BWMediatorProtocol> delegate = (id<BWMediatorProtocol>)target;
    if ( signature == nil ) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey : [NSString stringWithFormat:@"未找到\"%@\"的实现类", target],
        };
        
#if !DEBUG
        NSString *msg = [NSString stringWithFormat:@"%@ 没有实现 %@ 方法",
                         target, NSStringFromSelector(selector)];
        @throw [NSException exceptionWithName:@"方法调用错误" reason:msg userInfo:userInfo];
#else
        if ([delegate respondsToSelector:@selector(errors:)]) {
            [delegate errors:[NSError errorWithDomain:BWErrorDomain
                                                 code:BWModuleInvokeError
                                             userInfo:userInfo]];
        }
#endif
        return nil;
    }
    dispatch_queue_t queue = NULL;
    if ([delegate respondsToSelector:@selector(methodQueue)]) {
        queue = [delegate methodQueue];
    }
    if (queue == NULL) {
        queue = self.methodQueue;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:target];
    NSMutableArray *retainedArguments = [NSMutableArray array];
    [invocation bw_setArgumentWithArgs:argList retainedArguments:retainedArguments];
    [invocation retainArguments];
    __block id returnObj = nil;
    dispatch_async(queue, ^{
        [invocation invoke];
        
        if (retainedArguments.count > 0) {
            for (NSValue   *value in retainedArguments) {
                void *pointer = [value pointerValue];
                id obj = *((__unsafe_unretained id *)pointer);
                if (obj) {
                    CFRetain((__bridge CFTypeRef)(obj));
                }
            }
        }
        
        returnObj = [invocation bw_returnValue];
    });
    
    
    
    return returnObj;
}

#pragma mark -  getter
- (NSArray<NSString *> *)sortedModules
{
    if (_sortedModules == nil) {
        _sortedModules = [self.moduleClasses keysSortedByValueUsingComparator:^NSComparisonResult(Class class1, Class class2) {
            NSUInteger priority1 = BWModulePriorityDefault;
            NSUInteger priority2 = BWModulePriorityDefault;
            if ([class1 respondsToSelector:@selector(priority)]) {
                priority1 = [class1 priority];
            }
            if ([class2 respondsToSelector:@selector(priority)]) {
                priority2 = [class2 priority];
            }
            if(priority1 == priority2) {
                return NSOrderedSame;
            } else if(priority1 < priority2) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
    return _sortedModules;
}

@end
