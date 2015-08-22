//
//  TEALConfiguration.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/2/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALConfiguration.h"
#import "NSString+Tealium.h"

@implementation TEALConfiguration

#pragma mark - PUBLIC CLASS

+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName {
    
    TEALConfiguration *configuration = [[TEALConfiguration alloc] init];
    
    if (!configuration) {
        return nil;
    }
    
    // Default configuration
    configuration.accountName       = [accountName lowercaseString];
    configuration.profileName       = [profileName lowercaseString];
    configuration.environmentName   = [environmentName lowercaseString];
    configuration.useHTTP           = NO;
    configuration.pollingFrequency  = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
    configuration.logLevel          = TEALLogLevelNone;
    configuration.autotrackingLifecycleEnabled  = YES;
    configuration.autotrackingUIEventsEnabled = NO;
    configuration.autotrackingViewsEnabled = YES;
    configuration.autotrackingIvarsEnabled = NO;
    configuration.overridePublishSettingsURL = nil;
    configuration.overridePublishURL = nil;
    configuration.overrideDispatchURL = nil;
   
    configuration.audienceStreamProfile = @"main";
    
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

#pragma mark - PUBLIC INSTANCE

- (NSString *) instanceID {
    return [NSString stringWithFormat:@"%@_%@_%@", self.accountName, self.profileName, self.environmentName];
}

#pragma mark - PRIVATE INSTANCE

- (NSString *) description {
    
    NSDictionary *descriptionData = @{
                                          @"account - name":[NSString teal_dictionarySafeString:self.accountName],
                                          @"account - profile":[NSString teal_dictionarySafeString:self.profileName],
                                          @"account - target environment":[NSString teal_dictionarySafeString:self.environmentName],
                                          @"use http":[NSString teal_stringFromBool:self.useHTTP],
                                          @"polling frequency":[NSNumber numberWithUnsignedLong:self.pollingFrequency],
                                          @"log level":[NSNumber numberWithUnsignedInt:self.logLevel],
                                          @"autotracking ivars enabled":[NSString teal_stringFromBool:self.autotrackingIvarsEnabled],
                                          @"autotracking lifecycle enabled":[NSString teal_stringFromBool:self.autotrackingLifecycleEnabled],
                                          @"autotracking ui events enabled":[NSString teal_stringFromBool:self.autotrackingUIEventsEnabled],
                                          @"autotracking views enabled":[NSString teal_stringFromBool:self.autotrackingViewsEnabled],
                                          @"override publish settings url":[NSString teal_dictionarySafeString:self.overridePublishSettingsURL],
                                          @"override publish url":[NSString teal_dictionarySafeString:self.overridePublishURL],
                                          @"override dispatch url":[NSString teal_dictionarySafeString:self.overrideDispatchURL]
                                          };
    
    return [NSString teal_descriptionForObject:self description:@"Compile time options" fromDictionary:descriptionData];
}
@end
