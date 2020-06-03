//
//  NSInvocation+Mediator.m
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import "NSInvocation+Mediator.h"
#import <objc/runtime.h>

#import <UIKit/UIKit.h>

@implementation NSInvocation (Mediator)

- (void)bw_setArgument:(id)object atIndex:(NSUInteger)index {
#define PULL_AND_SET(type, selector) \
do { \
type val = [object selector]; \
[self setArgument:&val atIndex:(NSInteger)index]; \
} while (0)
    
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == 'r') {
        argType++;
    }
    
    if (strcmp(argType, "@\"NSString\"") == 0) {
        NSString *string = (NSString *)object;
        [self setArgument:&string atIndex:(NSInteger)index];
    }
    else if (strcmp(argType, "@\"NSArray\"") == 0) {
        NSArray *array = (NSArray *)object;
        [self setArgument:&array atIndex:(NSInteger)index];
    }
    else  if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        [self setArgument:&object atIndex:(NSInteger)index];
    } else if (strcmp(argType, @encode(char)) == 0) {
        PULL_AND_SET(char, charValue);
    } else if (strcmp(argType, @encode(int)) == 0) {
        PULL_AND_SET(int, intValue);
    } else if (strcmp(argType, @encode(short)) == 0) {
        PULL_AND_SET(short, shortValue);
    } else if (strcmp(argType, @encode(long)) == 0) {
        PULL_AND_SET(long, longValue);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        PULL_AND_SET(long long, longLongValue);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        PULL_AND_SET(unsigned char, unsignedCharValue);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        PULL_AND_SET(unsigned int, unsignedIntValue);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        PULL_AND_SET(unsigned short, unsignedShortValue);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        PULL_AND_SET(unsigned long, unsignedLongValue);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        PULL_AND_SET(unsigned long long, unsignedLongLongValue);
    } else if (strcmp(argType, @encode(float)) == 0) {
        PULL_AND_SET(float, floatValue);
    } else if (strcmp(argType, @encode(double)) == 0) {
        PULL_AND_SET(double, doubleValue);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        PULL_AND_SET(BOOL, boolValue);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        const char *cString = [object UTF8String];
        [self setArgument:&cString atIndex:(NSInteger)index];
        [self retainArguments];
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        [self setArgument:&object atIndex:(NSInteger)index];
    } else {
        NSCParameterAssert([object isKindOfClass:NSValue.class]);
        
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment([object objCType], &valueSize, NULL);
        
#if DEBUG
        NSUInteger argSize = 0;
        NSGetSizeAndAlignment(argType, &argSize, NULL);
        NSCAssert(valueSize == argSize, @"Value size does not match argument size in -scc_setArgument: %@ atIndex: %lu", object, (unsigned long)index);
#endif
        
        unsigned char valueBytes[valueSize];
        [object getValue:valueBytes];
        
        [self setArgument:valueBytes atIndex:(NSInteger)index];
    }
    
#undef PULL_AND_SET
}

- (id)bw_returnValue {
#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[self getReturnValue:&val]; \
return @(val); \
} while (0)
    
    const char *returnType = self.methodSignature.methodReturnType;
    // Skip const type qualifier.
    if (returnType[0] == 'r') {
        returnType++;
    }
    
    if (strcmp(returnType, @encode(id)) == 0 || strcmp(returnType, @encode(Class)) == 0 || strcmp(returnType, @encode(void (^)(void))) == 0) {
        __autoreleasing id returnObj;
        [self getReturnValue:&returnObj];
        return returnObj;
    } else if (strcmp(returnType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(returnType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(returnType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(returnType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(returnType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(returnType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(returnType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(returnType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(returnType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(returnType, @encode(void)) == 0) {
        return nil;
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(returnType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [self getReturnValue:valueBytes];
        
        return [NSValue valueWithBytes:valueBytes objCType:returnType];
    }
    
    return nil;
    
#undef WRAP_AND_RETURN
}

- (void)bw_setArgumentWithArgs:(va_list)arguments retainedArguments:(NSMutableArray *)retainedArguments;
{
    NSInteger argsCount = [self.methodSignature numberOfArguments];
    NSInteger idx = 2;
    if (self.selector == nil) {
        idx = 1;
    }
#define PULL_AND_SET(realType, type) \
do { \
realType value = (realType)va_arg(arguments, type); \
[self setArgument:&value atIndex:idx]; \
} while (0)
    for (; idx < argsCount; idx++) {
        const char *argType = [self.methodSignature getArgumentTypeAtIndex:idx];
        if (argType[0] == 'r') {
            argType++;
        }
        
        if (strcmp(argType, "@\"NSString\"") == 0) {
            PULL_AND_SET(NSString *, NSString *);
        }
        else if (strcmp(argType, "@\"NSArray\"") == 0) {
            PULL_AND_SET(NSArray *, NSArray *);
        }
        else if (strcmp(argType, @encode(BOOL)) == 0) {
            PULL_AND_SET(BOOL, int);
        }
        else if (strcmp(argType, @encode(long)) == 0) {
            PULL_AND_SET(long, long);
        }
        else if (strcmp(argType, @encode(unsigned long)) == 0) {
            PULL_AND_SET(unsigned long, unsigned long);
        }
        else if (strcmp(argType, @encode(char)) == 0) {
            PULL_AND_SET(char, int);
        } else if (strcmp(argType, @encode(int)) == 0) {
            PULL_AND_SET(int, int);
        } else if (strcmp(argType, @encode(short)) == 0) {
            PULL_AND_SET(short, int);
        }  else if (strcmp(argType, @encode(long long)) == 0) {
            PULL_AND_SET(long long, long long);
        } else if (strcmp(argType, @encode(unsigned char)) == 0) {
            PULL_AND_SET(unsigned char, int);
        } else if (strcmp(argType, @encode(unsigned int)) == 0) {
            PULL_AND_SET(unsigned int, unsigned int);
        } else if (strcmp(argType, @encode(unsigned short)) == 0) {
            PULL_AND_SET(unsigned short, int);
        }  else if (strcmp(argType, @encode(unsigned long long)) == 0) {
            PULL_AND_SET(unsigned long long, unsigned long long);
        } else if (strcmp(argType, @encode(float)) == 0) {
            PULL_AND_SET(float, double);
        } else if (strcmp(argType, @encode(double)) == 0) {
            PULL_AND_SET(double, double);
        }  else if (strcmp(argType, @encode(char *)) == 0) {
            PULL_AND_SET(char *, char *);
        } else if (strcmp(argType, @encode(void(^)(void))) == 0 ||
                   strcmp(argType, @encode(NSObject *)) == 0) {
            id value = (id)va_arg(arguments, id);
            [self setArgument:&value atIndex:idx];
            //            PULL_AND_SET(id, id);
        }
        else if (strcmp(argType, @encode(typeof(NSError **))) == 0 ) {
            void ** pointer = va_arg(arguments, void **);
            NSValue *errVal = [NSValue valueWithPointer:pointer];
            
            if (errVal) {
                [retainedArguments addObject:errVal];
            }
            NSError *__autoreleasing* errorPoint = (NSError *__autoreleasing*)[errVal pointerValue];
            [self setArgument:&errorPoint atIndex:idx];
        }
        else if (strcmp(argType, @encode(typeof([NSObject class]))) == 0 ) {
            PULL_AND_SET(Class, Class);
        }
        else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{CGRect"]) {
            PULL_AND_SET(CGRect, CGRect);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{CGPoint"]) {
            PULL_AND_SET(CGPoint, CGPoint);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{CGSize"]) {
            PULL_AND_SET(CGSize, CGSize);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{NSRange"]) {
            PULL_AND_SET(NSRange, NSRange);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{UIEdgeInsets"]) {
            PULL_AND_SET(UIEdgeInsets, UIEdgeInsets);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{CGAffineTransform"]) {
            PULL_AND_SET(CGAffineTransform, CGAffineTransform);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{UIOffset"]) {
            PULL_AND_SET(UIOffset, UIOffset);
        } else if ( [[NSString stringWithUTF8String:argType] hasPrefix:@"{CGVector"]) {
            PULL_AND_SET(CGVector, CGVector);
        }
    }
#undef PULL_AND_SET
}

@end
