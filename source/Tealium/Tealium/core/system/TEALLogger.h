//
//  TEALLog.h
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//
//  BRIEF: Logs should be requested only by the main tealium object unless otherwise necessary

#import <Foundation/Foundation.h>

/**
 *  Unsigned integer value that controls the verbosity level of any log output.
 */
typedef NS_ENUM(NSUInteger, TEALLogLevel){
    /**
     *  Nothing is logged to the console, this is the default.
     */
    TEALLogLevelNone = 1,
    /**
     *  Only errors reported.
     */
    TEALLogLevelProd,
    /**
     *  Provides warnings and errors only.
     */
    TEALLogLevelQA,
    /**
     *  Most verbose - Useful for debugging and verification during development.
     */
    TEALLogLevelDev


};

@interface TEALLogger : NSObject

+ (TEALLogLevel) logLevelFromString:(NSString*)string;

+ (NSString *) logLevelStringFromLogLevel:(TEALLogLevel) logLevel;

- (instancetype) initWithInstanceID:(NSString *)instanceID;

- (void) enable;

- (void) disable;

- (void) updateLogLevel:(TEALLogLevel)logLevel;

- (void) logProd:(NSString *) format, ...;

- (void) logQA:(NSString *) format, ...;

- (void) logDev:(NSString *) format, ...;

- (TEALLogLevel) currentLogLevel;

@end
