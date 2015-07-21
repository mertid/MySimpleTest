//
//  NSObject+TealiumAdditions.m
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSObject+TealiumAdditions.h"
#import <objc/runtime.h>

static CFStringRef  const TealiumCM_KVOUniqueIdentifier = CFSTR("TealiumAutotracking_KVOUniqueIdentifier");

@implementation NSObject (TealiumAdditions)

- (void)teal_setAutotrackingEnabled:(BOOL)enabled
{
    NSNumber *enableOnNumber = [NSNumber numberWithBool:enabled];
    objc_setAssociatedObject(self, &TealiumCM_KVOUniqueIdentifier, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)teal_autotrackingEnabled
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
