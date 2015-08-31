//
//  Tealium+MobileCompanion.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+MobileCompanion.h"
#import "Tealium+PrivateHeader.h"
#import "TEALMobileCompanion.h"
#import "TEALMobileCompanionDelegate.h"
#import <objc/runtime.h>

char const * const TEALKVO_MobileCompanion = "com.tealium.kvo.mobilecompanion";
NSString * const TEALKEY_MobileCompanion = @"com.tealium.mobilecompanion";

@interface Tealium() <TEALMobileCompanionDelegate>

@end

@implementation Tealium (MobileCompanion)

#pragma mark - PUBLIC INSTANCE

- (void) unlockMobileCompanion {
    
    [[self mobileCompanionInstance] reveal];
}

#pragma mark - PRIVATE INSTANCE

- (TEALMobileCompanion *) mobileCompanionInstance {
    
    id raw = [self moduleDataCopy][TEALKEY_MobileCompanion];
    if (![raw isKindOfClass:([TEALMobileCompanion class])]){
        return [self newMobileCompanionInstance];
    }
    
    TEALMobileCompanion *mobileCompanion = (TEALMobileCompanion*)raw;
    return mobileCompanion;
    
}

- (TEALMobileCompanion *) newMobileCompanionInstance {

    TEALMobileCompanion *mobileCompanion = [[TEALMobileCompanion alloc] initWithInstanceID:self.settings.instanceID];
    
    mobileCompanion.delegate = self;
    
    [self addModuleData:@{TEALKEY_MobileCompanion:mobileCompanion}];
    
    return mobileCompanion;

}


#pragma mark - HELPERS


#pragma mark - TEALMOBILECOMPANION DELEGATE

- (void) tealiumMobileCompanionDidDismiss {

    [self.operationManager addOperationWithBlock:^{
        
        [self removeModuleDataForKey:TEALKEY_MobileCompanion];
        
    }];

}

- (void) tealiumMobileCompanionRequestsSettings:(TEALMobileCompanion *)mobileCompanion {
    
}

- (void) tealiumMobileCompanionRequestsDataSources:(TEALMobileCompanion *)mobileCompanion forObject:(NSObject *)object {
    
}

- (void) tealiumMobileCompanionRequestsDispatchLogs:(TEALMobileCompanion *)mobileCompanion {
    
}

- (void) tealiumMobileCompanionEnabledTrace:(TEALMobileCompanion *)mobileCompanion withID:(NSString *)traceID {
    
}

- (void) tealiumMobileCompanionDisabledTrace:(TEALMobileCompanion *)mobileCompanion {
    
}

@end
