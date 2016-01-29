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

char const * const TEALKVOObjectCustomData =  "com.tealium.kvo.customdata";

@implementation NSObject (Tealium)

//- (NSDictionary *) teal_dataSources {
//    
//    NSDictionary *associatedDictionary = nil;
//    
//    associatedDictionary = objc_getAssociatedObject(self, TEALKVOObjectCustomData);
//
//    if (!associatedDictionary || ![associatedDictionary isKindOfClass:([NSDictionary class])]) {
//        associatedDictionary = nil;
//    }
//    
//    return associatedDictionary;
//}

//- (void) teal_setDataSources:(NSDictionary *)dataSources {
//    
//    NSDictionary *dataSourcesCopy =  nil;
//
//    if (!dataSources) {
//        dataSourcesCopy = [NSDictionary new];
//    } else {
//        dataSourcesCopy = [dataSources teal_stringifiedDictionary];
//    }
//    
//    objc_setAssociatedObject(self, TEALKVOObjectCustomData, dataSourcesCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//}


- (NSString *) teal_stringValue {

    if (![self isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@", self];
    }
    return [(NSString *)self copy];

}

@end
