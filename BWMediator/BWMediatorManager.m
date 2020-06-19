//
//  BWMediatorManager.m
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
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

@property (nonatomic, strong) NSDictionary *moduleClasses;
@property (nonatomic, strong) NSArray<NSString *> *sortedModules;

@property (nonatomic, strong) NSOperationQueue  *methodQueue;

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
        self.methodQueue  = [[NSOperationQueue alloc] init];
        self.methodQueue.name = @"com.bwmediator.method";
        self.methodQueue.maxConcurrentOperationCount = 3;
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
    id target = [self objectWithProtocol:protocol];
    
    if ( nil == target || [((NSObject *)target).class priority] < priority ) {
        return nil;
    }
    if (![target respondsToSelector:selector]) {
        [self sendError:target
        message:[NSString stringWithFormat:@"未找到\"%@\"的实现类", protocolKey]];
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

- (void)sendError:(id<BWMediatorProtocol>)target message:(NSString *)message; {
    if (! target || ! message) {
        return;
    }
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : message,
    };
    
    if ([target respondsToSelector:@selector(errors:)]) {
        [target errors:[NSError errorWithDomain:BWErrorDomain
                                           code:BWModuleInvokeError
                                       userInfo:userInfo]];
    }
}

- (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector; {
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (! signature) {
        [self sendError:target
                message:[NSString stringWithFormat:@"未找到\"%@\"的实现类", target]];
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:target];
    return invocation;
}

- (id)invokeWithTarget:(id)target selector:(SEL)selector arguments:(va_list)argList;
{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    __weak id<BWMediatorProtocol> delegate = (id<BWMediatorProtocol>)target;
    if ( signature == nil ) {
        [self sendError:target
                message:[NSString stringWithFormat:@"未找到\"%@\"的实现类", target]];
        return nil;
    }
    BOOL isMainThread = NO;
    NSOperationQueue *queue = self.methodQueue;
    if ([delegate respondsToSelector:@selector(isMainThread)]) {
        isMainThread = [delegate isMainThread];
    }
    if (isMainThread) {
        queue = NSOperationQueue.mainQueue;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:target];
    NSMutableArray *retainedArguments = [NSMutableArray array];
    [invocation bw_setArgumentWithArgs:argList retainedArguments:retainedArguments];
    [invocation retainArguments];

    if (isMainThread && NSOperationQueue.currentQueue == NSOperationQueue.mainQueue) {
        [invocation invoke];
    } else {
        
        NSInvocationOperation *operation
         = [[NSInvocationOperation alloc] initWithInvocation:invocation];
        /** If an exception was raised during the execution of the method or invocation,
         *  accessing this property raises that exception again. If the operation was
         *  cancelled or the invocation or method has a void return type, accessing
         *  this property raises an exception; see Result Exceptions.
         */
        //id returnObj = operation.result;
        [queue addOperations:@[operation] waitUntilFinished:YES];
        
    }
    
    if (retainedArguments.count > 0) {
        for (NSValue   *value in retainedArguments) {
            void *pointer = [value pointerValue];
            id obj = *((__unsafe_unretained id *)pointer);
            if (obj) {
                CFRetain((__bridge CFTypeRef)(obj));
            }
        }
    }
    
    id returnObj = [invocation bw_returnValue];
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
