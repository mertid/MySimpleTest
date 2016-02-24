//
//  TEALConfiguration+Collect.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALConfiguration+Collect.h"
#import "TEALConfiguration+PrivateHeader.h"

NSString * const TEALCollectOverrideDispatchURLKey = @"com.tealium.collect.override.dispatchURL";
NSString * const TEALS2SOverrideDispatchURLKey = @"com.tealium.s2s.override.dispatchURL";
NSString * const TEALCollectPollingFrequencyKey = @"com.tealium.collect.polling.frequency";

NSString * const TEALCollectProfileURLKey = @"";
NSString * const TEALCollectProfileDefinitionsURLKey = @"";
NSString * const TEALTraceIDKey = @"com.tealium.traceid";

@implementation TEALConfiguration (Collect)

#pragma mark - GETTERS

- (NSString *) overrideCollectDispatchURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    NSString *dispatchURL = nil;
    
    if (moduleData){
        dispatchURL = [moduleData[TEALCollectOverrideDispatchURLKey] copy];
    }
    
    return dispatchURL;
}

- (NSString * _Nullable) overrideS2SLegacyDispatchURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALS2SOverrideDispatchURLKey] copy];
    
}

- (TEALVisitorProfilePollingFrequency) collectPollingFrequency {
    
    NSMutableDictionary *moduleData =  [self moduleData];
    
    NSNumber *frequencyNumber = [moduleData[TEALCollectPollingFrequencyKey] copy];
    
    if (!frequencyNumber){
        
        // Default option
        moduleData[TEALCollectPollingFrequencyKey] = @(TEALVisitorProfilePollingFrequencyOnRequest);
        
        return TEALVisitorProfilePollingFrequencyOnRequest;
    }
    
    return [frequencyNumber integerValue];
}

- (NSString * _Nullable) overrideCollectProfileURL {
    
    // TODO:
    
    return nil;
}

- (NSString * _Nullable) overrideCollectProfileDefinitionsURL {
    
    // TODO:
    
    return nil;
}

#pragma mark - SETTERS

- (void) setOverrideCollectDispatchURL:(NSString *) overrideURL{
    
    [self setModuleObject:overrideURL
                   forKey:TEALCollectOverrideDispatchURLKey
               completion:nil];
    
    [self setModuleDescription:overrideURL forKey:@"override collect dispatch url"];
}

- (void) setOverrideS2SLegacyDispatchURL:(NSString *)overrideURL {
    
    [self setModuleObject:overrideURL
                   forKey:TEALS2SOverrideDispatchURLKey
               completion:nil];
    
    [self setModuleDescription:overrideURL forKey:@"override s2s dispatch url"];
    
}

- (void) setCollectPollingFrequency:(TEALVisitorProfilePollingFrequency)frequency {
    
    NSNumber *frequencyAsNumber = [NSNumber numberWithInteger:frequency];
    
    NSString *frequencyAsString = [self pollingFrequencyAsString:frequency];
    
    [self setModuleObject:frequencyAsNumber
                   forKey:TEALCollectPollingFrequencyKey
               completion:nil];
    
    [self setModuleDescription:frequencyAsString forKey:@"polling frequency"];
    
}

- (NSString *) pollingFrequencyAsString:(TEALVisitorProfilePollingFrequency)frequency {
    
    NSString *string = nil;
    
    switch (frequency) {
        case TEALVisitorProfilePollingFrequencyOnRequest:
            string = @"On Request";
            break;
        case TEALVisitorProfilePollingFrequencyAfterEveryEvent:
            string = @"Every Event";
        default:
            string = @"(unknown)";
            break;
    }
    
    return string;
    
}

- (void) setCollectProfileURL:(NSURL *)overrideURL {
    
    // TODO:
    
}

- (void) setCollectProfileDefinitionsURL:(NSURL *)overrideURL {
    
    // TODO:
    
}

@end
