//
//  NSString+TealiumAdditions.h
//  TealiumUtilities
//
//  Created by George Webster on 2/10/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tealium)

+ (NSString *) teal_stringFromBool:(BOOL)value;
+ (NSString *) teal_descriptionForObject:(NSObject *)object fromDictionary:(NSDictionary *)dictionary;
+ (NSString *) teal_dictionarySafeString:(NSString *)string;

@end
