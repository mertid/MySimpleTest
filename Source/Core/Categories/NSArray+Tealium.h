//
//  NSArray+TealiumAdditions.h
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Tealium)

- (NSArray *) teal_stringifiedArray;

- (BOOL) teal_containsObjectOfClass:(Class)klass;

@end
