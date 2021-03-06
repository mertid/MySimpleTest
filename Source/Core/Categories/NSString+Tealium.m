//
//  NSString+TealiumAdditions.m
//  TealiumUtilities
//
//  Created by George Webster on 2/10/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSString+Tealium.h"

@implementation NSString (Tealium)

+ (NSString *) teal_stringFromBool:(BOOL)value {

    return (value) ? @"YES" : @"NO";
}

+ (NSString *) teal_descriptionForObject:(NSObject *)object description:(NSString *)description fromDictionary:(NSDictionary *)dictionary{
    
    // Creates a description string from key values from dictionary

    NSString *displayClass              = NSStringFromClass([object class]);
    
    NSMutableString *descriptionString = [NSMutableString stringWithString:[NSString stringWithFormat:@"\r\r === %@ === \r", displayClass]];
    
    if (description){
        [descriptionString appendString:[NSString stringWithFormat:@"( %@ )\r", description]];
    }
    
    NSArray *keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in keys){
        NSString *keyValue = dictionary[key];
        if (keyValue) {
            [descriptionString appendString:[NSString stringWithFormat:@"%@:%@ \r", key, keyValue]];
        }
    }
    
    [descriptionString appendString:@"\r"];
    
    return [NSString stringWithString:descriptionString];
}


+ (NSString *) teal_dictionarySafeString:(NSString *)string {
    if (!string) {
        return @"";
    }
    return string;
}


@end
