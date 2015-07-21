//
//  NSObject+TealiumAdditions.h
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TealiumAdditions)

- (NSString *) teal_stringValue;
- (void)teal_setAutotrackingEnabled:(BOOL)enabled;
- (BOOL)teal_autotrackingEnabled;


@end
