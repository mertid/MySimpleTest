//
//  TEALLog.h
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//
//  BRIEF: Logs should be requested only by the main tealium object unless otherwise necessary

#import <Foundation/Foundation.h>

#import "TEALConfiguration.h"

@interface TEALLogger : NSObject

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (void) logNormal:(NSString *) format, ...;

- (void) logVerbose:(NSString *) format, ...;

@end
