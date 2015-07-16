//
//  TEALLog.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import "TEALLogger.h"

static TEALLogLevel _audienceStreamLogLevel;

@implementation TEALLogger

+ (void) setLogLevel:(TEALLogLevel)logLevel {

    _audienceStreamLogLevel = logLevel;
}

+ (void) logTargetLevel:(TEALLogLevel)targetLevel message:(NSString *)format, ... {

    BOOL shouldLog = NO;
    switch (targetLevel) {
        case TEALLogLevelNormal:
            shouldLog = (_audienceStreamLogLevel >= TEALLogLevelNormal);
            break;
        case TEALLogLevelVerbose:
            shouldLog = (_audienceStreamLogLevel >= TEALLogLevelVerbose);
            break;
        case TEALLogLevelExtremeVerbosity:
            shouldLog = (_audienceStreamLogLevel >= TEALLogLevelExtremeVerbosity);
            break;
        case TEALLogLevelNone:
            shouldLog = NO;
            break;
    }
    
    if (shouldLog && format) {

        NSString *message = nil;
        va_list args;
        va_start(args, format);
        message = [[NSString alloc] initWithFormat:format
                                         arguments:args];
        va_end(args);

        NSLog(@"%@", message);
    }
}

@end
