//
//  TEALSettings.m
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Composite of Configurations and Publish Settings (new, default or archived)

#import "TEALSettings.h"
#import "TEALNetworkHelpers.h"
#import "TEALError.h"
#import "TEALBlocks.h"
#import "TEALConfiguration+PrivateHeader.h"
#import "TEALURLSessionManager.h"
#import "TEALDataSourceConstants.h"

@interface TEALSettings()

@property (nonatomic, strong) TEALConfiguration *configuration;
@property (nonatomic, strong) TEALPublishSettings *publishSettings;
@property (nonatomic, strong) NSString *audienceStreamDispatchURLString;
@property (nonatomic, strong) NSString *mobilePublishSettingsURLString;
@property (nonatomic, strong) NSString *tiqPublishURLString;
@property (nonatomic, weak) NSString *visitorID;
@property (nonatomic, strong) NSURL *audienceStreamProfileURL;
@property (nonatomic, strong) NSURL *audienceStreamProfileDefinitionsURL;

@end

@implementation TEALSettings

#pragma mark - CLASS METHODS

+ (NSString *) dispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
    NSString *urlPrefix = @"https";
    
    if ([settings useHTTP]) {
        urlPrefix = @"http";
    }
    
    NSString *baseURLString = [NSString stringWithFormat:@"%@://datacloud.tealiumiq.com/vdata/i.gif?", urlPrefix];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    params[TEALCollectKey_Account]   = [settings account];
    params[TEALCollectKey_Profile]   = [settings asProfile];
    params[TEALCollectKey_VisitorID] = [settings visitorIDCopy];
    
    if (settings.traceID) {
        params[TEALCollectKey_TraceID] = settings.traceID;
    }
    
    NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
    
    return [baseURLString stringByAppendingString:queryString];
}

+ (NSString *) publishSettingsURLFromConfiguration:(TEALConfiguration *)configuration {
    
    if (configuration.overridePublishSettingsURL) {
        return configuration.overridePublishSettingsURL;
    }
    
    // Default
    NSString *urlPrefix = @"https:";
    
    if (configuration.useHTTP) {
        urlPrefix = @"http:";
    }
    
    return [NSString stringWithFormat:@"%@//tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?",
            urlPrefix,
            configuration.accountName,
            configuration.profileName,
            configuration.environmentName];
}

+ (NSString *) publishURLFromConfiguration:(TEALConfiguration *)configuration {
    
    if (configuration.overridePublishURL) {
        return configuration.overridePublishURL;
    }
    
    // Default
    NSString *urlPrefix = @"https:";
    
    if (configuration.useHTTP) {
        urlPrefix = @"http:";
    }
    
    return [NSString stringWithFormat:@"%@//tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?",
            urlPrefix,
            configuration.accountName,
            configuration.profileName,
            configuration.environmentName];
}

+ (NSURL *) profileURLFromSettings:(TEALSettings *)settings {
    
    if (![settings isValid]) {
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://visitor-service.tealiumiq.com/%@/%@/%@",
                           settings.account,
                           settings.asProfile,
                           [settings visitorIDCopy]];
    
    return [NSURL URLWithString:urlString];
}

+ (NSURL *) profileDefinitionsURLFromSettings:(TEALSettings *)settings {
    
    if (![settings isValid]) {
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://visitor-service.tealiumiq.com/datacloudprofiledefinitions/%@/%@",
                           [settings account],
                           [settings asProfile]];
    
    return [NSURL URLWithString:urlString];
}

#pragma mark - PUBLIC METHODS

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration {
    
    if (![TEALConfiguration isValidConfiguration:configuration]) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _configuration = configuration;
        NSString *urlString = [TEALSettings publishSettingsURLFromConfiguration:configuration];
        _publishSettings = [[TEALPublishSettings alloc] initWithURLString:urlString];
    }
    
    return self;
}

- (BOOL) audienceStreamEnabled {
    return self.publishSettings.enableAudienceStream;
}

- (BOOL) autotrackingApplicationInfoEnabled {
    
#warning REMOVE these auto NOs for production
    return NO;
    
    if (self.publishSettings.disableApplicationInfoAutotracking) return NO;
    return self.configuration.autotrackingApplicationInfoEnabled;
}

- (BOOL) autotrackingCarrierInfoEnabled {
    
    return NO;
    
    if (self.publishSettings.disableCarrierInfoAutotracking) return NO;
    return self.configuration.autotrackingCarrierInfoEnabled;
}

- (BOOL) autotrackingDeviceInfoEnabled {
    
    return NO;
    
    if (self.publishSettings.disableDeviceInfoAutotracking) return NO;
    return self.configuration.autotrackingDeviceInfoEnabled;
}

- (BOOL) autotrackingIvarsEnabled {
    
    return NO;
    
    if (self.publishSettings.disableiVarAutotracking) return NO;
    return self.configuration.autotrackingIvarsEnabled;
}

- (BOOL) autotrackingLifecycleEnabled {
    if (self.publishSettings.disableLifecycleAutotracking) return NO;
    return self.configuration.autotrackingLifecycleEnabled;
}

- (BOOL) autotrackingTimestampInfoEnabled {
    
    return NO;
    
    if (self.publishSettings.disableTimestampAutotracking) return NO;
    return self.configuration.autotrackingTimestampInfoEnabled;
}

- (BOOL) autotrackingUIEventsEnabled {
    if (self.publishSettings.disableUIEventAutotracking) return NO;
    return self.configuration.autotrackingUIEventsEnabled;
}

- (BOOL) autotrackingViewsEnabled {
    if (self.publishSettings.disableViewAutotracking) return NO;
    return self.configuration.autotrackingViewsEnabled;
}

- (BOOL) crashTrackingEnabled {
    if (self.publishSettings.disableCrashTracking) return NO;
    return self.configuration.crashTrackingEnabled;
}

- (BOOL) mobileCompanionEnabled {
    if (self.publishSettings.disableMobileCompanion) return NO;
    return self.configuration.mobileCompanionEnabled;
}

- (BOOL) remoteCommandsEnabled {
    return self.configuration.remoteCommandsEnabled;
}

- (BOOL) isValid {
    return ([TEALConfiguration isValidConfiguration:self.configuration] && self.publishSettings.status != TEALPublishSettingsStatusDisable);
}

- (BOOL) tagManagementEnabled {
    return self.publishSettings.enableTagManagement;
}

- (BOOL) useHTTP {
    return self.configuration.useHTTP;
}

- (NSString *) account {
    return self.configuration.accountName;
}

- (NSString *) asProfile {
    return self.configuration.audienceStreamProfile;
}

- (NSString *) tiqProfile {
    return self.configuration.profileName;
}

- (NSString *) environment {
    return self.configuration.environmentName;
}

- (NSString *) instanceID {
    return self.configuration.instanceID;
}

- (NSString *) dispatchURLString {
    if (!self.audienceStreamDispatchURLString) {
        self.audienceStreamDispatchURLString = [TEALSettings dispatchURLStringFromConfiguration:self];
    }
    return self.audienceStreamDispatchURLString;
}

- (NSString *) publishSettingsDescription {
    return self.publishSettings.description;
}

- (NSString *) publishSettingsURLString {
    if (!self.mobilePublishSettingsURLString){
        self.mobilePublishSettingsURLString = [self.publishSettings url];
    }
    return self.mobilePublishSettingsURLString;
}

- (NSString *) publishURLString {
    if (!self.tiqPublishURLString){
        self.tiqPublishURLString = [TEALSettings publishURLFromConfiguration:self.configuration];
    }
    return self.tiqPublishURLString;
}

//- (NSString *) visitorIDCopy {
//    if (!self.visitorID) {
//        return @"";
//    }
//    return [self.visitorID copy];
//}

- (NSUInteger) dispatchSize {
    return self.publishSettings.dispatchSize;
}

- (NSUInteger) logLevel {
    return self.configuration.logLevel;
}

- (NSUInteger) offlineDispatchQueueSize {
    return self.publishSettings.offlineDispatchQueueSize;
}

- (NSUInteger) pollingFrequency {
    return self.configuration.pollingFrequency;
}

- (NSURL *) profileURL {
    if (!self.audienceStreamProfileURL) {
        self.audienceStreamProfileURL = [TEALSettings profileURLFromSettings:self];
    }
    return self.audienceStreamProfileURL;
}

- (NSURL *) profileDefinitionsURL {
    if (!self.audienceStreamProfileDefinitionsURL) {
        self.audienceStreamProfileDefinitionsURL = [TEALSettings profileDefinitionsURLFromSettings:self];
    }
    return self.audienceStreamProfileDefinitionsURL;
}

- (void) fetchPublishSettingsWithCompletion:(TEALFetchPublishSettingsCompletionBlock)completion {
    
    if (!self.configuration) {
        return;
    }
    
    // Get Publish Settings
    
    NSString *baseURL = [TEALSettings publishSettingsURLFromConfiguration:self.configuration];
    NSDictionary *params = @{}; //[self.configuration mobilePublishSettingsURLParams];
    
    NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
    
    NSString *settingsURLString = [baseURL stringByAppendingString:queryString];
    
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:settingsURLString];
    
    if (!request) {
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeMalformed
                                      description:@"Settings request unsuccessful"
                                           reason:[NSString stringWithFormat:@"Failed to generate valid request from URL string: %@", settingsURLString]
                                       suggestion:@"Check the Account/Profile/Enviroment values in your configuration"];
        
        [self.publishSettings loadArchived];
        
        completion( self.publishSettings.status, error );
        return;
    }
    
    __weak TEALSettings *weakSelf = self;
    __weak TEALPublishSettings *weakPublishSettings = weakSelf.publishSettings;
    
    [self.urlSessionManager performRequest:request
                            withCompletion:^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
                                
                                if (connectionError) {
                                    
                                    [weakPublishSettings loadArchived];
                                    if (completion) completion( weakPublishSettings.status, connectionError);
                                    
                                    return;
                                }
                                
                                NSError *parseError = nil;
                                NSDictionary *parsedData = [weakPublishSettings mobilePublishSettingsFromHTMLData:data
                                                                                                 error:&parseError];
                                
                                if ([weakPublishSettings areValidRawPublishSettings:parsedData]) {
                                    [weakPublishSettings updateWithRawSettings:parsedData];
                                    if (completion) completion( weakPublishSettings.status, nil);
                                } else {
                                    [weakPublishSettings loadArchived];
                                    if (completion) completion( weakPublishSettings.status, parseError );
                                }
                                
                                
                            }];
    
    
}

- (void) loadArchivedSettings {
    [self.publishSettings loadArchived];
}

//- (void) setVisitorIDCopy:(NSString *)visitorID {
//    
//    self.visitorID = visitorID;
//}

@end
