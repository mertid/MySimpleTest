//
//  NSObject+TealiumAutotracking.m
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSObject+TealiumAutotracking.h"
#import <objc/runtime.h>

static CFStringRef  const TEALKVOAutotrackDatasources = CFSTR("TEALIUM_KVO_AUTOTRACKING_DATASOURCES");
static CFStringRef  const TEALKVOAutotrackIvars = CFSTR("TEALIUM_KVO_AUTOTRACKING_IVARS");

@implementation NSObject (TealiumAutotracking)

#pragma mark - PRIVATE CLASS


+ (NSDictionary *) teal_ivarDataForObject:(NSObject *)obj {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    __block NSDictionary *ivars = [NSObject teal_ivarDataForClass:[obj class]];
    
    NSArray *allKeys = [ivars allKeys];
    for (id key in allKeys){
        if (![key isKindOfClass:[NSObject class]]) continue;
        id aObject = [ivars objectForKey:key];
        
        if (![aObject isKindOfClass:[NSString class]] &&
            ![aObject isKindOfClass:[NSNumber class]] &&
            [aObject isKindOfClass:[NSObject class]]) aObject = NSStringFromClass([aObject class]);
        
        NSString * modKey = [NSString stringWithFormat:@"ivar_%@", key];
        if (aObject){
            mDict[modKey] = aObject;
            NSString *value = [NSString stringWithFormat:@"%@", aObject];
            if (value){
                mDict[modKey] = value;
            }
        }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:mDict];
    return dict;
    
}

+ (NSDictionary*) teal_ivarDataForClass:(id)klass{
    // Requires <objc/runtime.h>
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    unsigned int count;
    Ivar* ivars = class_copyIvarList([klass class], &count);
    for(unsigned int i = 0; i < count; ++i)
    {
        const char * ivarChar = ivar_getName(ivars[i]);
        NSString *ivarKey = [NSString stringWithUTF8String:ivarChar];
        SEL aSelector = NSSelectorFromString(ivarKey);
        if ([klass respondsToSelector:aSelector]) {
            id value;
            @try                            { value = [klass valueForKey:ivarKey];  }
            @catch (NSException *exception) {                                       }
            @finally                        {                                       }
            if (ivarKey && value){
                NSString *modKey = [NSString stringWithFormat:@"ivar_%@", ivarKey];
                mDict[modKey] = value;
            }
        }
    }
    free(ivars);
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}




#pragma mark - PUBLIC INSTANCE

- (void) teal_setAutotrackingEnabled:(BOOL)enabled
{
    NSNumber *enableOnNumber = [NSNumber numberWithBool:enabled];
    objc_setAssociatedObject(self, &TEALKVOAutotrackDatasources, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL) teal_autotrackingEnabled
{
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &TEALKVOAutotrackDatasources);
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}

- (void) teal_setAutotrackIvarsEnabled:(BOOL)enabled {
    NSNumber *enableOnNumber = [NSNumber numberWithBool:enabled];
    objc_setAssociatedObject(self, &TEALKVOAutotrackIvars, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL) teal_autotrackIvarsEnabled {
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &TEALKVOAutotrackIvars);
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}

- (NSDictionary *) teal_autotrackDataSources {
#warning COMPLETE
    return nil;
}

- (NSDictionary *) teal_autotrackIvarDataSources {
#warning This not producing data as expected
    return [NSObject teal_ivarDataForObject:self];
}

@end
