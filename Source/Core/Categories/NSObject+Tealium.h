//
//  NSObject+TealiumAdditions.h
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Tealium)

/**
 *
 */
- (NSDictionary *) teal_dataSources;

/**
 *  Sets a dictionary of key-value information that will polled for data when object
 *  is part of a autotracked call.
 */
- (void) teal_setDataSources:(NSDictionary *)dataSources;

/**
 *  Returns a string representation of the object that can be used in Collections.
 */
- (NSString *) teal_stringValue;



@end
