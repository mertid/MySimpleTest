//
//  TEALConfiguration.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/2/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALConfiguration.h"

@implementation TEALConfiguration

+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName {
    
    TEALConfiguration *configuration = [[TEALConfiguration alloc] init];
    
    if (!configuration) {
        return nil;
    }
    
    configuration.accountName       = accountName;
    configuration.profileName       = profileName;
    configuration.environmentName   = environmentName;
    configuration.useHTTP           = NO;
    configuration.pollingFrequency  = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
    configuration.logLevel          = TEALLogLevelNone;
   
    configuration.audienceStreamProfile = @"main";
    
    return configuration;
}

@end
