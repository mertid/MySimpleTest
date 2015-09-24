//
//  TEALException.h
//  Tealium
//
//  Created by Jason Koo on 9/24/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALLifecycleEvents.h"

@interface TEALExceptionEvents : TEALLifecycleEvents

- (void) loadFromDictionary:(NSDictionary *) dictionary;

- (void) resetLastExceptionInfo;

- (void) updateLastException:(NSException *) exception;

- (BOOL) hasLastException;

- (NSDictionary *) dataSources;

@end
