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

#ifndef TEAL_TARGET_WATCHOS
    
    
    return self.reachability.isReachable;

#else

#warning TODO

    // Use simple NSURL check
    
    return YES;
    
#endif
    
    // default - dispatch managers will report false sends, but will continue
    // running.
    
    return YES;
    
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
    
#ifndef TEAL_TARGET_WATCHOS
    return [self.reachability reachabilityDataSources];
#endif
    
    return @{};

}

@end
