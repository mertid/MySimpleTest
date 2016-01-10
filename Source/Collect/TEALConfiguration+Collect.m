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
    
    return [moduleData[TEALCollectOverrideDispatchURLKey] copy];
    
}

- (NSString * _Nullable) overrideS2SLegacyDispatchURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALS2SOverrideDispatchURLKey] copy];
    
}

- (TEALVisitorProfilePollingFrequency) collectPollingFrequency {
    
    NSDictionary *moduleData =  [self moduleData];
    
    NSNumber *frequencyNumber = [moduleData[TEALCollectOverrideDispatchURLKey] copy];
    
    if (!frequencyNumber){
        // Default option
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

- (NSString * _Nullable) traceID {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALTraceIDKey] copy];
    
}


#pragma mark - SETTERS

- (void) setOverrideCollectDispatchURL:(NSString *) overrideURL{
    
    [self setModuleObject:overrideURL forKey:TEALCollectOverrideDispatchURLKey];
    
    [self setModuleDescription:overrideURL forKey:@"override collect dispatch url"];
}

- (void) setOverrideS2SLegacyDispatchURL:(NSString *)overrideURL {
    
    [self setModuleObject:overrideURL forKey:TEALS2SOverrideDispatchURLKey];
    
    [self setModuleDescription:overrideURL forKey:@"override s2s dispatch url"];
    
}

- (void) setCollectPollingFrequency:(TEALVisitorProfilePollingFrequency)frequency {
    
    NSNumber *frequencyAsNumber = [NSNumber numberWithInteger:frequency];
    
    NSString *frequencyAsString = [NSString stringWithFormat:@"%i", frequency];
    
    [self setModuleObject:frequencyAsNumber forKey:TEALCollectPollingFrequencyKey];
    
    [self setModuleDescription:frequencyAsString forKey:@"polling frequency"];
    
}

- (void) setCollectProfileURL:(NSURL *)overrideURL {
    
    // TODO:
    
}

- (void) setCollectProfileDefinitionsURL:(NSURL *)overrideURL {
    
    // TODO:
    
}

- (void) setTraceID:(NSString *)traceID {
    
    [self setModuleObject:traceID forKey:TEALTraceIDKey];
    
}

@end
