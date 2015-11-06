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
@property (nonatomic, strong) NSString *privateCollectDispatchURLString;
@property (nonatomic, strong) NSString *privateS2SLegacyDispatchURLString;
@property (nonatomic, strong) NSString *mobilePublishSettingsURLString;
@property (nonatomic, strong) NSString *tiqPublishURLString;
@property (nonatomic, weak) NSString *visitorID;
@property (nonatomic, strong) NSURL *audienceStreamProfileURL;
@property (nonatomic, strong) NSURL *audienceStreamProfileDefinitionsURL;
@property (nonatomic, strong) NSDate *lastFetch;

@end

@implementation TEALSettings

#pragma mark - CLASS METHODS

+ (NSString *) collectDispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
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

+ (NSString *) s2SLegacyDispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
    NSString *urlPrefix = @"https";
    
    if ([settings useHTTP]) {
        urlPrefix = @"http";
    }
    
    NSString *account = [settings account];
    NSString *profile = @"main"; // Collect calls should always go to main
    NSString *queue = @"8"; // 2-AS Live Events, 8-Legacy S2S, 10-both

    NSString *baseURLString = [NSString stringWithFormat:@"%@://datacloud.tealiumiq.com/%@/%@/%@/i.gif?", urlPrefix, account, profile, queue];

    return baseURLString;
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

- (BOOL) collectEnabled {

#warning RESET after dev
    return NO;

    return self.publishSettings.enableCollect;
    
}

- (BOOL) autotrackingApplicationInfoEnabled {
    
    if (self.publishSettings.disableApplicationInfoAutotracking) return NO;
    return self.configuration.autotrackingApplicationInfoEnabled;
}

- (BOOL) autotrackingCarrierInfoEnabled {
    
    if (self.publishSettings.disableCarrierInfoAutotracking) return NO;
    return self.configuration.autotrackingCarrierInfoEnabled;
}

- (BOOL) autotrackingDeviceInfoEnabled {
    
    if (self.publishSettings.disableDeviceInfoAutotracking) return NO;
    return self.configuration.autotrackingDeviceInfoEnabled;
}

- (BOOL) autotrackingIvarsEnabled {
        
    if (self.publishSettings.disableiVarAutotracking) return NO;
    return self.configuration.autotrackingIvarsEnabled;
}

- (BOOL) autotrackingLifecycleEnabled {
    if (self.publishSettings.disableLifecycleAutotracking) return NO;
    return self.configuration.autotrackingLifecycleEnabled;
}

- (BOOL) autotrackingTimestampInfoEnabled {
        
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

- (BOOL) autotrackingCrashesEnabled {
    if (self.publishSettings.disableCrashAutotracking) return NO;
    return self.configuration.autotrackingCrashesEnabled;
}

- (BOOL) s2SLegacyEnabled {

#warning RESET after dev
    return YES;
    
    return self.publishSettings.enableS2SLegacy;
}

- (BOOL) libraryShouldDisable {

    return (self.publishSettings.status == TEALPublishSettingsStatusDisable);
}

- (BOOL) mobileCompanionEnabled {
    if (self.publishSettings.disableMobileCompanion) return NO;
    return self.configuration.mobileCompanionEnabled;
}

- (BOOL) remoteCommandsEnabled {
    return self.configuration.remoteCommandsEnabled;
}

- (BOOL) isValid {
    return ([TEALConfiguration isValidConfiguration:self.configuration] &&
            self.publishSettings.status != TEALPublishSettingsStatusDisable);
}

- (BOOL) tagManagementEnabled {
    
#warning RESET after dev
    return NO;

    return self.publishSettings.enableTagManagement;
}

- (BOOL) useHTTP {
    return self.configuration.useHTTP;
}

- (BOOL) wifiOnlySending {
    
    return self.publishSettings.enableSendWifiOnly;
}

- (BOOL) goodBatteryLevelOnlySending {
    
    return !self.publishSettings.enableLowBatterySuppress;
}

- (BOOL) isDefaultPublishSettings {
    
    return (self.publishSettings.status == TEALPublishSettingsStatusDefault);
    
}

- (double) daysDispatchesValid {
    return self.publishSettings.numberOfDaysDispatchesAreValid;
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

- (NSString *) collectDispatchURLString {
    if (!self.privateCollectDispatchURLString) {
        self.privateCollectDispatchURLString = [TEALSettings collectDispatchURLStringFromConfiguration:self];
    }
    return self.privateCollectDispatchURLString;
}

- (NSString *) s2SLegacyDispatchURLString {
    
    if (!self.privateS2SLegacyDispatchURLString){
        self.privateS2SLegacyDispatchURLString = [TEALSettings s2SLegacyDispatchURLStringFromConfiguration:self];
    }
    return self.privateS2SLegacyDispatchURLString;
}

- (NSString *) configurationDescription {
    return self.configuration.description;
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

- (TEALLogLevel) logLevel {
    
    NSString *logLevelString = self.publishSettings.overrideLogLevel;
    
    if (!logLevelString){
        
        // Automatic off of env setting
        logLevelString = self.configuration.environmentName;
        
    }
    
    TEALLogLevel logLevel = [TEALLogger logLevelFromString:logLevelString];
    
    return logLevel;
    
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


- (NSURLRequest *) publishSettingsRequest {
    
    NSString *baseURL = [TEALSettings publishSettingsURLFromConfiguration:self.configuration];
    NSDictionary *params = @{}; //[self.configuration mobilePublishSettingsURLParams];
    NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
    NSString *settingsURLString = [baseURL stringByAppendingString:queryString];
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:settingsURLString];
    
    return request;
}

- (void) fetchNewRawPublishSettingsWithCompletion:(TEALBooleanCompletionBlock)completion{
    
    // Generate request
    NSURLRequest *request = [self publishSettingsRequest];
    
    // Bail out checks:
    NSError *preFetchError = nil;
    
    if (!request) {
        preFetchError = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"Settings request unsuccessful", @"")
                                  reason:NSLocalizedString(@"Failed to generate valid request.", @"")
                              suggestion:NSLocalizedString(@"Check the Account/Profile/Enviroment values in your configuration", @"")];
        
    }
    if (!self.configuration){
        preFetchError = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Unable to fetch new publish settings", @"")
                                  reason:NSLocalizedString(@"No configuration available.", @"")
                              suggestion:NSLocalizedString(@"Wait for configuration to become available.", @"")];
    }
    if (![self canFetchNow]) {
        preFetchError = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Unable to fetch new publish settings", @"")
                                  reason:NSLocalizedString(@"Can not fetch at this time", @"")
                              suggestion:NSLocalizedString(@"Check prior minutes between refresh setting.", @"")];
    }
    
    if (preFetchError){
        if (completion){
            completion (NO, preFetchError);
        }
        return;
    }

    
    // Perform request
    __block typeof(self) __weak weakSelf = self;

    [self.urlSessionManager performRequest:request
                            withCompletion:^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
                             
        BOOL success = NO;
        NSError *error = nil;
        NSDictionary *parsedData = [TEALPublishSettings mobilePublishSettingsFromHTMLData:data
                                                                                    error:&error];
        if (!error &&
            ![TEALPublishSettings correctMPSVersionRawPublishSettings:parsedData]) {
            // No MPS Settings for current library version
            error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                 description:NSLocalizedString(@"No mobile publish settings found.", @"")
                                      reason:NSLocalizedString(@"Mobile Publish Settings for current version may not have been published.", @"")
                                  suggestion:NSLocalizedString(@"Add the correct Mobile Publish Setting version, re-publish, or update library.", @"")];
        }
    
        if (!error &&
            connectionError) {
            error = connectionError;
        }
            
        if (!error &&
            [weakSelf.publishSettings areNewRawPublishSettings:parsedData]){
            
            [weakSelf.publishSettings updateWithRawSettings:parsedData];
            
        }
        
        if (completion) {
            completion( success, error);
        }
        
    }];
    
}


#pragma mark - PRIVATE

- (BOOL) canFetchNow {
    
    BOOL fetchAcceptable = NO;
    NSDate *now = [NSDate date];
    
    if (self.lastFetch){
        double elapsedTime = [now timeIntervalSinceDate:self.lastFetch];
        if (elapsedTime > [self.publishSettings minutesBetweenRefresh] * 60) {
            fetchAcceptable = YES;
            self.lastFetch = now;
        }
    } else {
        fetchAcceptable = YES;
        self.lastFetch = now;
    }
    
    
    return fetchAcceptable;
}

@end
