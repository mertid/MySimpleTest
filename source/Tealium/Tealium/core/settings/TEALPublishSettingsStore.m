//
//  TEALPublishSettingsStore.m
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALPublishSettingsStore.h"
#import "TEALPublishSettings.h"
#import "TEALOperationManager.h"

@interface TEALPublishSettingsStore()

@property (nonatomic, strong) NSString *instanceId;

@end

@implementation TEALPublishSettingsStore

- (instancetype) initWithInstanceID:(NSString *)instanceId;{
    
    if (!instanceId) {
        return nil;
    }
    
    if ([[instanceId stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return nil;
    }
    
    
    self = [super init];
    
    if (self){
        
        _instanceId = instanceId;
    
    }
    
    return self;
}

- (NSString *) instanceIDCopy {
    return [self.instanceId copy];
}

- (TEALPublishSettings *) unarchivePublishSettings {
    
    NSData *settingsData = [[NSUserDefaults standardUserDefaults] objectForKey:self.instanceId];
    
    id settings = nil;
    
    if (!settingsData){
        return nil;
    }
    
    settings = [NSKeyedUnarchiver unarchiveObjectWithData:settingsData];
    
    if (![settings isKindOfClass:([TEALPublishSettings class])]){
        
        return nil;
    }
    
    return settings;
    
}

- (void) archivePublishSettings:(TEALPublishSettings *)settings {
    
    if (!settings) {
        
        return;
    }
    
    NSData *settingsData = [NSKeyedArchiver archivedDataWithRootObject:settings];
    
    // TODO: re-enable background thread operation
//    [[self.configuration operationManager] addIOOperationWithBlock:^{
    
        [[NSUserDefaults standardUserDefaults] setObject:settingsData
                                                  forKey:self.instanceId];
        [[NSUserDefaults standardUserDefaults] synchronize];
//    }];
}
@end
