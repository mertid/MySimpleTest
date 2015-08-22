//
//  NSObject+TealiumAdditions.m
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSObject+Tealium.h"
#import <objc/runtime.h>
#import "NSDictionary+Tealium.h"

static CFStringRef  const TealiumCM_KVOUniqueIdentifier = CFSTR("TealiumAutotracking_KVOUniqueIdentifier");

char const * const TealiumKVO_CustomData =                      "com.tealium.customdata";

@implementation NSObject (Tealium)

- (NSDictionary *) teal_dataSources {
    
    NSDictionary *associatedDictionary = nil;
    
    associatedDictionary = objc_getAssociatedObject(self, TealiumKVO_CustomData);

    if (!associatedDictionary || ![associatedDictionary isKindOfClass:([NSDictionary class])]) {
        associatedDictionary = nil;
    }
    
    return associatedDictionary;
}


- (void) teal_setDataSources:(NSDictionary *)dataSources {
    
    NSDictionary *dataSourcesCopy =  nil;

    if (!dataSources) {
        dataSourcesCopy = [NSDictionary new];
    } else {
        dataSourcesCopy = [dataSources teal_stringifiedDictionary];
    }
    
    objc_setAssociatedObject(self, TealiumKVO_CustomData, dataSourcesCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (void) teal_setAutotrackingEnabled:(BOOL)enabled
{
    NSNumber *enableOnNumber = [NSNumber numberWithBool:enabled];
    objc_setAssociatedObject(self, &TealiumCM_KVOUniqueIdentifier, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL) teal_autotrackingEnabled
{
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &TealiumCM_KVOUniqueIdentifier);
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}


- (NSString *) teal_stringValue {

    if (![self isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@", self];
    }
    return [(NSString *)self copy];

}

@end
