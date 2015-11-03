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

#pragma mark - PUBLIC CLASS

+ (TEALPublishSettings *) unarchivePublishSettingsForInstanceID:(NSString *)instanceID {
    
    NSData *settingsData = [[NSUserDefaults standardUserDefaults] objectForKey:instanceID];
    
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

+ (void) archivePublishSettings:(TEALPublishSettings *)settings {
    
    if (!settings) {
        
        return;
    }
    
    NSData *settingsData = [NSKeyedArchiver archivedDataWithRootObject:settings];
    
    [[NSUserDefaults standardUserDefaults] setObject:settingsData
                                              forKey:settings.url];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
