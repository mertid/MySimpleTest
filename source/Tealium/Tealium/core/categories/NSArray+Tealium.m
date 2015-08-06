//
//  NSArray+TealiumAdditions.m
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSArray+Tealium.h"
#import "NSObject+Tealium.h"

@implementation NSArray (Tealium)

- (NSArray *) teal_stringifiedArray {

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    for (NSObject *obj in self) {
        
        NSString *cleaned = [obj teal_stringValue];
        [result addObject:cleaned];
    }
    return result;
}

@end
