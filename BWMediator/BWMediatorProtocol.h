//
//  BWMediatorProtocol.h
//  BWMediator
//
//  Created by CHENXIUWU699 on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NSUInteger BWModulePriority;
static const BWModulePriority BWModulePriorityRequired = 1000;
static const BWModulePriority BWModulePriorityHigh = 750;
static const BWModulePriority BWModulePriorityDefault = 500;
static const BWModulePriority BWModulePriorityLow = 250;

struct BW_KeyValue {
    __unsafe_unretained NSString *key;
    __unsafe_unretained NSString *value;
};

#define BW_KeyValue_EXPORT(key, value, idx) __attribute__((used, section("__DATA,__mediator.data"))) \
static const struct BW_KeyValue __BW##idx= (struct BW_KeyValue){key, value};

FOUNDATION_EXPORT NSString *const BWErrorDomain;

@protocol BWMediatorProtocol <NSObject, UIApplicationDelegate>

@optional
- (void)errors:(NSError *)error;
// 设置Module的优先级, (0 ~ 1000)
+ (NSUInteger)priority;

/**
* The queue that will be used to call all exported methods. If omitted, this
* will call on a default background queue, which is avoids blocking the main
* thread.
*
* If the methods in your module need to interact with UIKit methods, they will
* probably need to call those on the main thread, as most of UIKit is main-
* thread-only. You can tell BWMediator to call your module methods on the
* main thread by returning a reference to the main queue, like this:
*
* - (dispatch_queue_t)methodQueue
* {
*   return dispatch_get_main_queue();
* }
*
* If you don't want to specify the queue yourself, but you need to use it
* inside your class (e.g. if you have internal methods that need to dispatch
* onto that queue), you can just add `@synthesize methodQueue = _methodQueue;`
* and the bridge will populate the methodQueue property for you automatically
* when it initializes the module.
*/
@property (nonatomic, strong, readonly) dispatch_queue_t methodQueue;

/**
* if A class implementation , It's object will not be saved forever
*
* so It's object lifecycle will not be managed
*
* if sharedInstance isn't a singleton, It will be ignore
*/
+ (instancetype)sharedInstance;


@end

NS_ASSUME_NONNULL_END
