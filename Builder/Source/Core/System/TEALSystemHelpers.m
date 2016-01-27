//
//  TEALSystemHelpers.m
//  Tealium Mobile Library
//
//  Created by George Webster on 12/29/14.
//  Copyright (c) 2014 Tealium Inc. All rights reserved.
//

#import "TEALSystemHelpers.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/machine.h>
#import "TEALDataSourceConstants.h"
#import "TEALVersion.h"

@implementation TEALSystemHelpers

+ (NSDictionary*) compositeDictionaries:(NSArray*)dictionaries {
    
    NSMutableDictionary *compositeDictionary = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dictionary in dictionaries) {
        if ([dictionary isKindOfClass:([NSDictionary class])]){
            [compositeDictionary addEntriesFromDictionary:dictionary];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:compositeDictionary];
    
}

//+ (NSString *) mpsVersionNumber {
//    // Version number with .x and .x.x versions stripped
//    NSString *version = TEALLibraryVersion;
//    
//#warning CORRECT for double dot increments, ie 1.1.1 -> 1
//    
//    return [NSString stringWithFormat:@"%i", [version intValue]];
//}

@end
