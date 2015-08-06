//
//  TEALLog.h
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALConfiguration.h"

#define TEAL_LogNormal(s,...) [TEALLogger logTargetLevel:TEALLogLevelNormal message:(s),##__VA_ARGS__];
#define TEAL_LogVerbose(s,...) [TEALLogger logTargetLevel:TEALLogLevelVerbose message:(s),##__VA_ARGS__];


@interface TEALLogger : NSObject

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (void) logNormal:(NSString *) format, ...;

- (void) logVerbose:(NSString *) format, ...;

+ (void) setLogLevel:(TEALLogLevel)logLevel;

+ (void) logTargetLevel:(TEALLogLevel)targetLevel message:(NSString *)format, ...;

@end
