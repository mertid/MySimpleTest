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
@property (nonatomic) BOOL isDisabled;

@end

@implementation TEALLogger

+ (NSString *) messageHeaderWithInstanceID:(NSString *) instanceID {
    NSString *version = TEALLibraryVersion;
    return [NSString stringWithFormat:@"TEALIUM %@: instance %@: ", version, instanceID];
}

+ (TEALLogLevel) logLevelFromString:(NSString*)string {
    
    TEALLogLevel level = TEALLogLevelNone;
    
    if ([[string lowercaseString] isEqualToString:@"dev"]){
        level = TEALLogLevelDev;
    } else if ([[string lowercaseString] isEqualToString:@"qa"]){
        level = TEALLogLevelQA;
    } else if ([[string lowercaseString] isEqualToString:@"prod"]){
        level = TEALLogLevelProd;
    }
    return level;
}

+ (NSString *) logLevelStringFromLogLevel:(TEALLogLevel) logLevel {
    
    NSString *string = nil;
    switch (logLevel) {
        case TEALLogLevelDev:
            string = @"dev";
            break;
        case TEALLogLevelQA:
            string = @"qa";
            break;
        case TEALLogLevelProd:
            string = @"prod";
            break;
        default:
            string = @"none";
            break;
    }
    
    return string;
}

- (instancetype) initWithInstanceID:(NSString *)instanceID{
    
    self = [super init];
    if (self) {
        _messageHeader = [TEALLogger messageHeaderWithInstanceID:instanceID];
    }
    return self;
}

- (void) enable {
    
    self.isDisabled = NO;
    
}

- (void) disable {
    
    self.isDisabled = YES;
    
}

- (void) updateLogLevel:(TEALLogLevel)logLevel {
    self.logLevel = logLevel;
}

- (void) logProd:(NSString *) format, ... {
    
    if (self.isDisabled) return;
    
    NSString *message = nil;
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format
                                     arguments:args];
    va_end(args);
    
//    NSString *warning = NSLocalizedString(@"!!! WARNING !!!", @"Console log string prefix for warning messages.");
//    NSString *finalMessage = [NSString stringWithFormat:@"%@: %@", warning, message];
    [self logVerbosity:TEALLogLevelProd message:message];
}

- (void) logQA:(NSString *) format, ... {
    
    if (self.isDisabled) return;

    NSString *message = nil;
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format
                                     arguments:args];
    va_end(args);
    
    [self logVerbosity:TEALLogLevelQA message:message];
}

- (void) logDev:(NSString *) format, ...{
    
    if (self.isDisabled) return;

    NSString *message = nil;
    va_list args;
    va_start(args, format);
    
    message = [[NSString alloc] initWithFormat:format
                                     arguments:args];
    va_end(args);
    
    [self logVerbosity:TEALLogLevelDev message:message];
}

- (void) logVerbosity:(TEALLogLevel)logLevel message:(NSString *) message{
        
    BOOL shouldLog = NO;
    switch (logLevel) {
        case TEALLogLevelProd:
            shouldLog = (self.logLevel >= TEALLogLevelProd);
            break;
        case TEALLogLevelQA:
            shouldLog = (self.logLevel >= TEALLogLevelQA);
            break;
        case TEALLogLevelDev:
            shouldLog = (self.logLevel >= TEALLogLevelDev);
            break;
        default:
            break;
    }
    
    if (shouldLog == YES && message) {
    
        NSLog(@"%@%@", self.messageHeader, message);
    }
}

- (TEALLogLevel) currentLogLevel {
    return self.logLevel;
}
@end
