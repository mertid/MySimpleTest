//
//  TEALConfiguration.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/2/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALConfiguration.h"
#import "NSString+TealiumAdditions.h"

@implementation TEALConfiguration

- (NSString *) description {
    
    NSDictionary *descriptionDict = @{
                                      @"account":[NSString teal_dictionarySafeString:self.accountName],
                                      @"tiq profile":[NSString teal_dictionarySafeString:self.profileName],
                                      @"audiencestream profile":[NSString teal_dictionarySafeString:self.audienceStreamProfile],
                                      @"use http":[NSString teal_stringFromBool:self.useHTTP],
                                      @"polling frequency":[NSNumber numberWithUnsignedLong:self.pollingFrequency],
                                      @"log level":[NSNumber numberWithUnsignedInt:self.logLevel],
                                      @"lifecycle enabled":[NSString teal_stringFromBool:self.lifecycleEnabled],
                                      @"autotracking ui events enabled":[NSString teal_stringFromBool:self.autotrackingUIEventsEnabled],
                                      @"autotracking views enabled":[NSString teal_stringFromBool:self.autotrackingViewsEnabled],
                                      @"override publish settings url":[NSString teal_dictionarySafeString:self.overridePublishSettingsURL],
                                      @"override publish url":[NSString teal_dictionarySafeString:self.overridePublishURL]
                                      };
    
    return [NSString teal_descriptionForObject:self fromDictionary:descriptionDict];
}
+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName {
    
    TEALConfiguration *configuration = [[TEALConfiguration alloc] init];
    
    if (!configuration) {
        return nil;
    }
    
    // Default configuration
    configuration.accountName       = accountName;
    configuration.profileName       = profileName;
    configuration.environmentName   = environmentName;
    configuration.useHTTP           = NO;
    configuration.pollingFrequency  = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
    configuration.logLevel          = TEALLogLevelNone;
    configuration.lifecycleEnabled  = YES;
    configuration.autotrackingUIEventsEnabled = NO;
    configuration.autotrackingViewsEnabled = YES;
    configuration.overridePublishSettingsURL = nil;
    configuration.overridePublishURL = nil;
   
    configuration.audienceStreamProfile = @"main";
    
    return configuration;
}

+ (BOOL) validConfiguration:(TEALConfiguration *)configuration {
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
@end
