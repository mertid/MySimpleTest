//
//  TEALConfiguration.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/2/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALConfiguration.h"
#import "NSString+Tealium.h"

@interface TEALConfiguration()

// Hidden
@property (nonatomic) BOOL autotrackingApplicationInfoEnabled;
@property (nonatomic) BOOL autotrackingCarrierInfoEnabled;
@property (nonatomic) BOOL autotrackingTimestampInfoEnabled;
@property (nonatomic) NSString *overridePublishSettingsVersion;
@property (nonatomic) NSMutableDictionary *privateModuleData;
@property (nonatomic) NSMutableDictionary *privateModuleDescriptionData;
@property (nonatomic) dispatch_queue_t queue;


// v5.1
@property (nonatomic) BOOL autotrackingCrashesEnabled;
@property (nonatomic) BOOL autotrackingDeviceInfoEnabled;
@property (nonatomic) BOOL autotrackingIvarsEnabled;
@property (nonatomic) BOOL autotrackingLifecycleEnabled;
@property (nonatomic) BOOL autotrackingUIEventsEnabled;
@property (nonatomic) BOOL autotrackingViewsEnabled;
@property (nonatomic) BOOL mobileCompanionEnabled;
//@property (nonatomic) NSString *privateInstanceID;

@end

@implementation TEALConfiguration

#pragma mark - PUBLIC CLASS

+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName{
    
    TEALConfiguration *configuration = [[TEALConfiguration alloc] init];
    
    if (!configuration) {
        return nil;
    }
    
    // Default configuration
    configuration.accountName       = [accountName lowercaseString];
    configuration.profileName       = [profileName lowercaseString];
    configuration.environmentName   = [environmentName lowercaseString];
    configuration.useHTTP           = NO;
    configuration.pollingFrequency  = TEALVisitorProfilePollingFrequencyOnRequest;
    configuration.autotrackingApplicationInfoEnabled = YES;
    configuration.autotrackingCarrierInfoEnabled = YES;
    configuration.autotrackingDeviceInfoEnabled = YES;
    configuration.autotrackingIvarsEnabled = NO;
    configuration.autotrackingLifecycleEnabled  = YES;
    configuration.autotrackingTimestampInfoEnabled = YES;
    configuration.autotrackingUIEventsEnabled = NO;
    configuration.autotrackingViewsEnabled = YES;
    configuration.autotrackingCrashesEnabled = YES;
    configuration.mobileCompanionEnabled = YES;
    configuration.remoteCommandsEnabled = YES;  // Only enables if TagManagement is turned on
    configuration.overridePublishSettingsURL = nil;
    configuration.overridePublishSettingsVersion = nil;
    configuration.overridePublishURL = nil;
//    configuration.overrideCollectDispatchURL = nil;
    configuration.overrideS2SLegacyDispatchURL = nil;
//    configuration.moduleData = [NSMutableDictionary new];
    
    NSString *fullQueueName = [NSString stringWithFormat:@"tealium.configuration.queue.%@.%@.%@", accountName, profileName, environmentName];
    const char * queueName = [fullQueueName UTF8String];
    configuration.queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    
    return configuration;
}

+ (BOOL) isValidConfiguration:(TEALConfiguration *)configuration {
    if (!configuration.accountName) return NO;
    if (!configuration.profileName) return NO;
    if (!configuration.environmentName) return NO;
    
    NSString *accountSpacesRemoved = [configuration.accountName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([accountSpacesRemoved isEqualToString:@""]) return NO;
    
    NSString *profileSpacesRemoved = [configuration.profileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([profileSpacesRemoved isEqualToString:@""]) return NO;
    
    NSString *environmentSpacesRemoved = [configuration.environmentName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([environmentSpacesRemoved isEqualToString:@""]) return NO;
    
    return YES;
}




#pragma mark - MODULE DATA
- (NSMutableDictionary *) moduleData {
    
    if (!self.privateModuleData){
        self.privateModuleData = [NSMutableDictionary new];
    }
    
    return self.privateModuleData;
    
}

- (id) moduleObjectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync(self.queue, ^{
        obj = [self moduleData][key];
    });
    
    return obj;
}

- (void) setModuleObject:(id<NSCopying, NSSecureCoding>)object
                  forKey:(id<NSCopying, NSSecureCoding>)aKey {
    
    dispatch_barrier_async(self.queue, ^{
        
        [self moduleData][aKey] = object;
        
    });
}

- (NSMutableDictionary *) moduleDescriptionData {
    
    if (!self.privateModuleDescriptionData) {
        self.privateModuleDescriptionData = [NSMutableDictionary new];
    }
    
    return self.privateModuleDescriptionData;
}

- (void) setModuleDescription:(NSString *) description
                  forKey:(NSString *)aKey {
    
    dispatch_barrier_async(self.queue, ^{
    
        [self moduleDescriptionData][aKey] = description;
        
    });
}

#pragma mark - PRIVATE INSTANCE

- (NSDictionary *) baseDescriptionData {
    
    return @{
              @"instance id":[NSString teal_dictionarySafeString:self.instanceID],
              @"account - name":[NSString teal_dictionarySafeString:self.accountName],
              @"account - profile":[NSString teal_dictionarySafeString:self.profileName],
              @"account - target environment":[NSString teal_dictionarySafeString:self.environmentName],
              @"use http":[NSString teal_stringFromBool:self.useHTTP],
              @"polling frequency":@(self.pollingFrequency),
              //                                          @"autotracking device info enabled":[NSString teal_stringFromBool:self.autotrackingDeviceInfoEnabled],
              //                                          @"autotracking ivars enabled":[NSString teal_stringFromBool:self.autotrackingIvarsEnabled],
              //                                          @"autotracking lifecycle enabled":[NSString teal_stringFromBool:self.autotrackingLifecycleEnabled],
              //                                          @"autotracking ui events enabled":[NSString teal_stringFromBool:self.autotrackingUIEventsEnabled],
              //                                          @"autotracking views enabled":[NSString teal_stringFromBool:self.autotrackingViewsEnabled],
              //                                          @"crash tracking enabled":[NSString teal_stringFromBool:self.autotrackingCrashesEnabled],
              //                                          @"mobile companion enabled":[NSString teal_stringFromBool:self.mobileCompanionEnabled],
              //                                          @"override mps publish settings version":[NSString teal_dictionarySafeString:self.overridePublishSettingsVersion],
              @"remote commands enabled":[NSString teal_stringFromBool:self.remoteCommandsEnabled],
              @"override publish settings url":[NSString teal_dictionarySafeString:self.overridePublishSettingsURL],
              @"override publish url":[NSString teal_dictionarySafeString:self.overridePublishURL],
//              @"override dispatch url":[NSString teal_dictionarySafeString:self.overrideCollectDispatchURL],
              @"override s2s legacy dispatch url":[NSString teal_dictionarySafeString:self.overrideS2SLegacyDispatchURL],
              
              };
    
}

- (NSDictionary *) finalDescriptionData {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[self baseDescriptionData]];
    
    [mDict addEntriesFromDictionary:[self moduleDescriptionData]];
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

- (NSString *) description {
    
    NSDictionary *descriptionData = [self finalDescriptionData];
    
    return [NSString teal_descriptionForObject:self description:@"Compile time options" fromDictionary:descriptionData];
    
}
@end
