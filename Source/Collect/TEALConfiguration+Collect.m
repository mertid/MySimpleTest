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

@implementation TEALConfiguration (Collect)

- (NSString *) overrideCollectDispatchURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALCollectOverrideDispatchURLKey] copy];
    
}

- (NSString * _Nullable) overrideS2SLegacyDispatchURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALS2SOverrideDispatchURLKey] copy];
    
}

- (TEALVisitorProfilePollingFrequency) pollingFrequency {
    
    NSDictionary *moduleData =  [self moduleData];
    
    NSNumber *frequencyNumber = [moduleData[TEALCollectOverrideDispatchURLKey] copy];
    
    if (!frequencyNumber){
        // Default option
        return TEALVisitorProfilePollingFrequencyOnRequest;
    }
    
    return [frequencyNumber integerValue];
}


- (void) setOverrideCollectDispatchURL:(NSString *) overrideURL{
    
    [self setModuleObject:overrideURL forKey:TEALCollectOverrideDispatchURLKey];
    
    [self setModuleDescription:overrideURL forKey:@"override collect dispatch url"];
}

- (void) setOverrideS2SLegacyDispatchURL:(NSString *)overrideURL {
    
    [self setModuleObject:overrideURL forKey:TEALS2SOverrideDispatchURLKey];
    
    [self setModuleDescription:overrideURL forKey:@"override s2s dispatch url"];
    
}

- (void) setPollingFrequency:(TEALVisitorProfilePollingFrequency)frequency {
    
    NSNumber *frequencyAsNumber = [NSNumber numberWithInteger:frequency];
    
    NSString *frequencyAsString = [NSString stringWithFormat:@"%i", frequency];
    
    [self setModuleObject:frequencyAsNumber forKey:TEALCollectPollingFrequencyKey];
    
    [self setModuleDescription:frequencyAsString forKey:@"polling frequency"];
    
}


@end
