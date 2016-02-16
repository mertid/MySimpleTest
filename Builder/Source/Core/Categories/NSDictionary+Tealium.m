//
//  NSDictionary+TealiumAdditions.m
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSDictionary+Tealium.h"
#import "NSArray+Tealium.h"
#import "NSObject+Tealium.h"

@implementation NSDictionary (Tealium)

//- (NSDictionary *) teal_stringifiedDictionary {
//    
//#warning This is causing crashes
//    
//    NSMutableDictionary *cleanedDict = [NSMutableDictionary dictionary];
//    
//    NSArray *allKeys = [self allKeys];
//    for (unsigned int i = 0; i < [allKeys count]; i++){
//        
//        @autoreleasepool {
//            
//            id key = allKeys[i];
//            id obj = self[key];
//            
//            NSString *newKey = [key teal_stringValue];
//            
//            if ([obj isKindOfClass:[NSArray class]]) {
//                NSArray *ar = (NSArray *)obj;
//                cleanedDict[newKey] = [ar teal_stringifiedArray];
//            } else {
//                
//                cleanedDict[newKey] = [obj teal_stringValue];
//            }
//        }
//    }
//
//    return [NSDictionary dictionaryWithDictionary:cleanedDict];
//
//}

+ (NSDictionary*) teal_compositeDictionaries:(NSArray*)dictionaries {
    
    NSMutableDictionary *compositeDictionary = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dictionary in dictionaries) {
        if ([dictionary isKindOfClass:([NSDictionary class])]){
            [compositeDictionary addEntriesFromDictionary:dictionary];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:compositeDictionary];
    
}

- (NSArray *) teal_arrayForDebugDisplay {

    NSMutableArray *sortedArray = [NSMutableArray array];
    
    NSArray *keys = [self allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *key in sortedKeys) {
        @autoreleasepool {
            
            id object = self[key];
            NSString *string = [NSString stringWithFormat:@"%@ = %@", key, object];
            [sortedArray addObject:string];
        }
    }
    
    return [NSArray arrayWithArray:sortedArray];
}

@end
