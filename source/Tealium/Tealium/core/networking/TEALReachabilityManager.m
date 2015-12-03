//
//  TEALReachabilityManager.m
//  TealiumiOS
//
//  Created by Jason Koo on 11/30/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALReachabilityManager.h"

#ifndef TEAL_TARGET_WATCHOS
#import "TEALReachability.h"
#endif

@interface TEALReachabilityManager()

#ifndef TEAL_TARGET_WATCHOS
@property (nonatomic, strong) TEALReachability *reachability;
#endif

@end

@implementation TEALReachabilityManager


+ (instancetype) reachabilityManagerWithHostName:(NSString *)hostname {
    
    return [[self alloc] initWithHostName:hostname];
    
}

- (instancetype) initWithHostName:(NSString *)hostname {
    
    self = [super init];
    if (self){
        
#ifndef TEAL_TARGET_WATCHOS
        _reachability = [TEALReachability reachabilityWithHostName:hostname];
#endif
        
    }
    return self;
    
}


- (BOOL) isReachable {
    
    BOOL canReach = YES;
    
#ifndef TEAL_TARGET_WATCHOS
    
#warning TODO
    // Use simple NSURL check
    
    
#else
    
#warning TODO
    // Use reachability manager
    
#endif
    
    
    return canReach;
    
}

- (BOOL) isReachableBlockEnabled {
    
    
#ifndef TEAL_TARGET_WATCHOS
    
    return self.reachability.reachableBlock? TRUE: FALSE;
    
#endif
    
    return NO;
    
}

- (BOOL) isReachableViaWifi {
    
#ifndef TEAL_TARGET_WATCHOS
    
    return [self.reachability isReachableViaWiFi];
    
#endif
    
    return NO;
    
}

- (void) startListeningForReachabilityChanges {
    
#ifndef TEAL_TARGET_WATCHOS
    
    [self.reachability startNotifier];
    
#endif
    
}

- (void) reachabilityChanged:(void (^)(BOOL canReach))responseBlock {
    
#ifndef TEAL_TARGET_WATCHOS
    
    self.reachability.reachableBlock = ^(TEALReachability *reachability) {
        
        responseBlock(YES);
        
    };
    
    self.reachability.unreachableBlock = ^(TEALReachability *reachability){
        
        responseBlock(NO);
        
    };
    
#endif
    
}

- (NSDictionary *) reachabilityDataSources {
    // Currently just returning connection data sources if available
    
#ifndef TEAL_TARGET_WATCHOS
    return [self.reachability connectionDataSources];
#endif
    return @{};

}

@end
