//
//  TEALLog.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import "TEALLogger.h"
#import "TEALDataSourceConstants.h"

@interface TEALLogger()

@property (nonatomic) TEALLogLevel logLevel;
@property (nonatomic, strong) NSString *messageHeader;

@end

@implementation TEALLogger

+ (NSString *) messageHeaderFromConfiguration:(TEALConfiguration *) configuration {
    NSString *version = TEALLibraryVersion;
    NSString *instanceID = configuration? configuration.instanceID:@"(unknown instance id)";
    
    return [NSString stringWithFormat:@"TEALIUM %@: instance %@: ", version, instanceID];
}

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration{
    self = [super init];
    if (self) {
        
        _logLevel = configuration? configuration.logLevel: TEALLogLevelWarningsOnly;
        _messageHeader = [TEALLogger messageHeaderFromConfiguration:configuration];
    }
    return self;
}

- (void) logWarning:(NSString *) format, ... {
    
    NSString *message = nil;
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format
                                     arguments:args];
    va_end(args);
    
    NSString *warning = NSLocalizedString(@"!!! WARNING !!!", @"Console log string prefix for warning messages.");
    NSString *finalMessage = [NSString stringWithFormat:@"%@: %@", warning, message];
    [self logVerbosity:TEALLogLevelWarningsOnly message:finalMessage];
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

- (void) logVerbosity:(TEALLogLevel)logLevel message:(NSString *) message{
    
#warning Log warning levels still displaying logs for Normal and Verbose
    
    BOOL shouldLog = NO;
    switch (logLevel) {
        case TEALLogLevelWarningsOnly:
            shouldLog = (self.logLevel >= TEALLogLevelWarningsOnly);
            break;
        case TEALLogLevelNormal:
            shouldLog = (self.logLevel >= TEALLogLevelNormal);
            break;
        case TEALLogLevelVerbose:
            shouldLog = (self.logLevel >= TEALLogLevelVerbose);
            break;
        default:
            break;
    }
    
    if (shouldLog == YES && message) {
    
        NSLog(@"%@%@", self.messageHeader, message);
    }
}

@end
