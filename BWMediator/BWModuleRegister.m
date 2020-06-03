//
//  BWModuleRegister.m
//  BWMediator
//
//  Created by CHENXIUWU699 on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWMediatorProtocol.h"

#import <objc/runtime.h>

#import <dlfcn.h>
#import <mach-o/getsect.h>

#ifdef __LP64__
typedef uint64_t BWExportValue;
typedef struct section_64 BWExportSection;
#define BWGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t BWExportValue;
typedef struct section BWExportSection;
#define BWGetSectByNameFromHeader getsectbynamefromheader
#endif

static inline NSMutableDictionary<NSString*, Class>* BWCreateModuleKeyValues(void)
{
    static NSMutableDictionary<NSString*, Class>* dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
    });
    return dictionary;
}
#pragma MARK: Runtime Register
Protocol* BWRegisterModuleClass(Class cls, Protocol *protocol)
{
    unsigned int outCount;
        Protocol *proto;
        Protocol * __unsafe_unretained *list = class_copyProtocolList(cls, &outCount);
        for (int idx = 0; idx < outCount; idx++) {
            Protocol *item = list[idx];
            if ( protocol_conformsToProtocol(item, protocol) ) {
                proto = item;
                break;
            }
        }
        free(list);
        return proto;
}

void BWRegisterModule(Class);
void BWRegisterModule(Class moduleClass)
{
    NSMutableDictionary *dictioanry = BWCreateModuleKeyValues();
    
    Protocol *superProtocol = @protocol(BWMediatorProtocol);
    if (! [moduleClass conformsToProtocol:superProtocol]) {
        return;
    }
    
    Protocol *proto =  BWRegisterModuleClass(moduleClass, superProtocol);
    // Register module
    [dictioanry setObject:moduleClass forKey:NSStringFromProtocol(proto)];
}


#pragma MARK: Mach-O Register

NSDictionary<NSString*, Class>* BWGetAllModules(void) {
    NSMutableDictionary *dictioanry = BWCreateModuleKeyValues();
    
    Dl_info info;
    dladdr((const void *)&BWGetAllModules, &info);
    
    const BWExportValue mach_header = (BWExportValue)info.dli_fbase;
    const BWExportSection *section = BWGetSectByNameFromHeader((void *)mach_header, "__SCM", "__scm.data");
    if (section == NULL) return nil;
    
    int addrOffset = sizeof(struct BW_KeyValue);
    for (BWExportValue addr = section->offset;
         addr < section->offset + section->size;
         addr += addrOffset) {
        struct BW_KeyValue entry = *(struct BW_KeyValue *)(mach_header + addr);

        if (entry.key == nil) {
            continue;
        }
        NSString *entryKey = (NSString *)entry.key;
        Class cls = NSClassFromString(entry.value);
        if ( protocol_conformsToProtocol(NSProtocolFromString(entryKey), @protocol(BWMediatorProtocol)) &&
            NULL != cls) {
            [dictioanry setObject:cls forKey:entryKey];
        }
    }
    return dictioanry.copy;
}
