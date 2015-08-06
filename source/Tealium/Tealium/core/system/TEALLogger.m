//
//  TEALLog.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import "TEALLogger.h"
#import "TEALSystemHelpers.h"

static TEALLogLevel _audienceStreamLogLevel;

@interface TEALLogger()

@property (nonatomic) TEALLogLevel logLevel;
@property (nonatomic, strong) NSString *messageHeader;
@end

@implementation TEALLogger

+ (NSString *) messageHeaderFromConfiguration:(TEALConfiguration *) configuration {
    NSString *version = [TEALSystemHelpers tealiumIQlibraryVersion];
    NSString *accountProfileEnvironment = [NSString stringWithFormat:@"%@/%@/%@", configuration.accountName, configuration.profileName, configuration.environmentName];
    
    return [NSString stringWithFormat:@"TEALIUM %@: instance:%@: ", version, accountProfileEnvironment];
}

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration{
    self = [super init];
    if (self) {
        
        _logLevel = configuration.logLevel;
        _messageHeader = [TEALLogger messageHeaderFromConfiguration:configuration];
    }
    return self;
}

- (void) logNormal:(NSString *) format, ... {
    
    NSString *message = nil;
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format
                                     arguments:args];
    va_end(args);
    
    [self logVerbosity:TEALLogLevelNormal message:message];
}

- (void) logVerbose:(NSString *) format, ...{
    
    NSString *message = nil;
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format
                                     arguments:args];
    va_end(args);
    
    [self logVerbosity:TEALLogLevelVerbose message:message];
}

- (void) logVerbosity:(TEALLogLevel)logLeval message:(NSString *) message{
    
    BOOL shouldLog = NO;
    switch (self.logLevel) {
        case TEALLogLevelNormal:
            shouldLog = (self.logLevel >= TEALLogLevelNormal);
            break;
        case TEALLogLevelVerbose:
            shouldLog = (self.logLevel >= TEALLogLevelVerbose);
            break;
        case TEALLogLevelNone:
            shouldLog = NO;
            break;
    }
    
    if (shouldLog && message) {
    
        NSLog(@"%@%@", self.messageHeader, message);
    }
}

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

        NSString *version = [TEALSystemHelpers tealiumIQlibraryVersion];
        
        NSLog(@"TEALIUM %@: %@", version, message);
    }
}

@end
