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

NSString * const TEALPublishSettingsStoreKey = @"com.tealium.publishsettingsstore";

@implementation TEALPublishSettingsStore

#pragma mark - PUBLIC CLASS

+ (TEALPublishSettings *) unarchivePublishSettingsForInstanceID:(NSString *)instanceID {
    
    NSDictionary *publishSettings = [[NSUserDefaults standardUserDefaults] objectForKey:TEALPublishSettingsStoreKey];
    
    if (!publishSettings){
        
        return nil;
        
    }
    
    NSData *settingsData = publishSettings[instanceID];
    
    if (!settingsData){
        
        return nil;
    }
    
    id settings = nil;
    
    settings = (TEALPublishSettings*)[NSKeyedUnarchiver unarchiveObjectWithData:settingsData];
    
//    if (![settings isKindOfClass:[TEALPublishSettings class]]){
//        
//        return nil;
//    }
    
    return settings;
    
}

+ (void) archivePublishSettings:(TEALPublishSettings *)settings {
    
    if (!settings) {
        
        return;
    }
    
    NSData *settingsData = [NSKeyedArchiver archivedDataWithRootObject:settings];
    
    if (!settings.url) {
     
        return;
        
    }
    
    NSDictionary *newPublishSettings = [self newPublishSettingsWithData:settingsData
                                                                 forKey:settings.url];
    
    [[NSUserDefaults standardUserDefaults] setObject:newPublishSettings
                                              forKey:TEALPublishSettingsStoreKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *) newPublishSettingsWithData:(NSData *)data forKey:(NSString*)key{
    
    NSDictionary *publishSettings = [[NSUserDefaults standardUserDefaults] objectForKey:TEALPublishSettingsStoreKey];
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    [mDict addEntriesFromDictionary:publishSettings];
    
    mDict[key] = data;
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

@end
