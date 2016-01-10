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
#import "TEALPublishSettings.h"
#import "TEALURLSessionManager.h"
#import "TEALDataSourceConstants.h"

@interface TEALSettings()

@property (nonatomic, strong) TEALConfiguration *configuration;
@property (nonatomic, strong) TEALPublishSettings *privatePublishSettings;
@property (nonatomic, strong) NSString *mobilePublishSettingsURLString;
@property (nonatomic, strong) NSString *tiqPublishURLString;
@property (nonatomic, strong) NSDate *lastFetch;
@property (nonatomic, weak) NSString *visitorID;

@end

@implementation TEALSettings

#pragma mark - CLASS METHODS

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

//+ (NSURL *) profileURLFromSettings:(TEALSettings *)settings {
//    
//    if (![settings isValid]) {
//        return nil;
//    }
//    
//    NSString *urlPrefix = @"https:";
//    
//    if ([settings useHTTP]) {
//        urlPrefix = @"http:";
//    }
//    
//    NSString *urlString = [NSString stringWithFormat:@"%@//visitor-service.tealiumiq.com/%@/%@/%@",
//                           urlPrefix,
//                           settings.account,
//                           settings.asProfile,
//                           [settings visitorIDCopy]];
//    
//    return [NSURL URLWithString:urlString];
//}
//
//+ (NSURL *) profileDefinitionsURLFromSettings:(TEALSettings *)settings {
//    
//    if (![settings isValid]) {
//        return nil;
//    }
//    
//    NSString *urlPrefix = @"https:";
//    
//    if ([settings useHTTP]) {
//        urlPrefix = @"http:";
//    }
//    
//    NSString *urlString = [NSString stringWithFormat:@"%@//visitor-service.tealiumiq.com/datacloudprofiledefinitions/%@/%@",
//                           urlPrefix,
//                           [settings account],
//                           [settings asProfile]];
//    
//    return [NSURL URLWithString:urlString];
//}

#pragma mark - PUBLIC METHODS

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration {
    
    if (![TEALConfiguration isValidConfiguration:configuration]) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _configuration = configuration;
    }
    
    return self;
}

- (BOOL) autotrackingApplicationInfoEnabled {
    
    if ([self publishSettings].disableApplicationInfoAutotracking) return NO;
    return self.configuration.autotrackingApplicationInfoEnabled;
}

- (BOOL) autotrackingCarrierInfoEnabled {
    
    if ([self publishSettings].disableCarrierInfoAutotracking) return NO;
    return self.configuration.autotrackingCarrierInfoEnabled;
}

- (BOOL) autotrackingDeviceInfoEnabled {
    
    if ([self publishSettings].disableDeviceInfoAutotracking) return NO;
    return self.configuration.autotrackingDeviceInfoEnabled;
}

- (BOOL) autotrackingIvarsEnabled {
        
    if ([self publishSettings].disableiVarAutotracking) return NO;
    return self.configuration.autotrackingIvarsEnabled;
}

- (BOOL) autotrackingLifecycleEnabled {
    if ([self publishSettings].disableLifecycleAutotracking) return NO;
    return self.configuration.autotrackingLifecycleEnabled;
}

- (BOOL) autotrackingTimestampInfoEnabled {
        
    if ([self publishSettings].disableTimestampAutotracking) return NO;
    return self.configuration.autotrackingTimestampInfoEnabled;
}

- (BOOL) autotrackingUIEventsEnabled {
    if ([self publishSettings].disableUIEventAutotracking) return NO;
    return self.configuration.autotrackingUIEventsEnabled;
}

- (BOOL) autotrackingViewsEnabled {
    if ([self publishSettings].disableViewAutotracking) return NO;
    return self.configuration.autotrackingViewsEnabled;
}

- (BOOL) autotrackingCrashesEnabled {
    if ([self publishSettings].disableCrashAutotracking) return NO;
    return self.configuration.autotrackingCrashesEnabled;
}

- (BOOL) libraryShouldDisable {

    return ([self publishSettings].status == TEALPublishSettingsStatusDisable);
}

- (BOOL) mobileCompanionEnabled {
    if ([self publishSettings].disableMobileCompanion) return NO;
    return self.configuration.mobileCompanionEnabled;
}

- (BOOL) remoteCommandsEnabled {
    return self.configuration.remoteCommandsEnabled;
}

- (BOOL) isValid {
    return ([TEALConfiguration isValidConfiguration:self.configuration] &&
            [self publishSettings].status != TEALPublishSettingsStatusDisable);
}

- (BOOL) tagManagementEnabled {

    return [self publishSettings].enableTagManagement;
}

- (BOOL) useHTTP {
    return self.configuration.useHTTP;
}

- (BOOL) wifiOnlySending {
    
    return [self publishSettings].enableSendWifiOnly;
}

- (BOOL) goodBatteryLevelOnlySending {
    
    return ![self publishSettings].enableLowBatterySuppress;
}

- (BOOL) isDefaultPublishSettings {
    
    return ([self publishSettings].status == TEALPublishSettingsStatusDefault);
    
}

- (double) daysDispatchesValid {
    return [self publishSettings].numberOfDaysDispatchesAreValid;
}

- (NSString *) account {
    return self.configuration.accountName;
}

- (NSString *) asProfile {
    return @"main";
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

- (NSString *) configurationDescription {
    return self.configuration.description;
}

- (NSString *) publishSettingsDescription {
    return [self publishSettings].description;
}

- (NSString *) publishSettingsURLString {
    if (!self.mobilePublishSettingsURLString){
        self.mobilePublishSettingsURLString = [[self publishSettings] url];
    }
    return self.mobilePublishSettingsURLString;
}

- (NSString *) publishURLString {
    if (!self.tiqPublishURLString){
        self.tiqPublishURLString = [TEALSettings publishURLFromConfiguration:self.configuration];
    }
    return self.tiqPublishURLString;
}

- (NSUInteger) dispatchSize {
    return [self publishSettings].dispatchSize;
}

- (NSString *) logLevelString {
    
    NSString * finalLogLevelString = self.configuration.environmentName;

    if (!finalLogLevelString){
        
        finalLogLevelString = [[self publishSettings] overrideLogLevel];

    }
    
    return finalLogLevelString;
    
}

- (NSUInteger) offlineDispatchQueueSize {
    return [self publishSettings].offlineDispatchQueueSize;
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
    NSDate *now = [NSDate date];
    
    // Bail out checks:
    NSError *preFetchError = nil;
    
    if (!request) {
        preFetchError = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"Settings request unsuccessful", @"")
                                  reason:NSLocalizedString(@"Failed to generate valid request.", @"")
                              suggestion:NSLocalizedString(@"Check the Account/Profile/Enviroment values in your configuration", @"")];
        
    }
    
    if (!preFetchError &&
        !self.configuration){
        preFetchError = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Unable to fetch new publish settings", @"")
                                  reason:NSLocalizedString(@"No configuration available.", @"")
                              suggestion:NSLocalizedString(@"Wait for configuration to become available.", @"")];
    }
    
    double minutesToNextFetch = [self minutesBeforeNextFetchFromDate:now];
    if (!preFetchError &&
        minutesToNextFetch > 0.0) {
        
        NSString * reason = [NSString stringWithFormat:@"Can not fetch at this time - %f minutes to end of refresh timeout.", minutesToNextFetch];
        preFetchError = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Unable to fetch new publish settings", @"")
                                  reason:reason
                              suggestion:NSLocalizedString(@"Wait for end of timeout or change prior minutes between refresh setting.", @"")];
        
    }
    
    if (preFetchError){
        if (completion){
            completion (NO, preFetchError);
        }
        return;
    }
    
    // Perform request
    self.lastFetch = now;
    __block typeof(self) __weak weakSelf = self;

    [self.urlSessionManager performRequest:request
                            withCompletion:^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
                             
        NSError *error = nil;
                  
        NSDictionary *parsedData = nil;

        TEALPublishSettings *publishSettings = [weakSelf publishSettings];
                        
        if ([response respondsToSelector:@selector(statusCode)]){
            
            if (response.statusCode != 200){
                
                error = connectionError;

            }
                                    
        }
                                
        // For future MPS config location - currently ignoring any error from this
        parsedData = [TEALPublishSettings mobilePublishSettingsFromJSONFile:data error:nil];
                                
        if (!error &&
            !parsedData){
         
            // Fallback to current mobile.html MPS var
            parsedData = [TEALPublishSettings mobilePublishSettingsFromHTMLData:data error:&error];
            
        }
            
        if (!error &&
            ![publishSettings correctMPSVersionRawPublishSettings:parsedData]) {
            
            // No MPS Settings for current library version
            error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                 description:NSLocalizedString(@"No mobile publish settings for current library version found.", @"")
                                      reason:NSLocalizedString(@"Mobile Publish Settings for current version may not have been published.", @"")
                                  suggestion:NSLocalizedString(@"Activate the correct Mobile Publish Setting version in TIQ, re-publish, or update library.", @"")];
        }
    
        if (!error &&
            connectionError) {
            error = connectionError;
        }
        
                                
        if (!error &&
            !publishSettings){
            
            NSString *urlString = [TEALSettings publishSettingsURLFromConfiguration:self.configuration];
            
            NSString *errorReaseon = [NSString stringWithFormat:@"Could not init publish settings with url: %@", urlString];
            
            error = [TEALError errorWithCode:TEALErrorCodeException
                                  description:NSLocalizedString(@"Unable to update Publish Settings.", @"")
                                       reason:errorReaseon
                                   suggestion:NSLocalizedString(@"Check override publish setting.", @"")];
        }
                                
                                
        // Bail out
        if (error){
            if (completion){
                completion( NO, error);
            }
            return;
        }
            
        // Init or Update Publish Settings
        if ([publishSettings areNewRawPublishSettings:parsedData]){

            [publishSettings updateWithRawSettings:parsedData];
            
        }
        
        // Return successful completion if new settings found or if exsisting okay
        if (completion) {
            completion( YES, error);
        }
        
    }];
    
}


#pragma mark - PRIVATE

- (TEALPublishSettings *) publishSettings {
    
    if (!self.privatePublishSettings){
        
        self.privatePublishSettings = [self newPublishedSettings];
    }
    
    return self.privatePublishSettings;
    
}

- (TEALPublishSettings *) newPublishedSettings {
    
    // Will load archive if available
    
    NSString *urlString = [TEALSettings publishSettingsURLFromConfiguration:self.configuration];
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:urlString];
    NSString *override = self.configuration.overridePublishSettingsVersion;
    
    if (override){
        settings.publishSettingsVersion = override;
    } else {
        settings.publishSettingsVersion = TEALDefaultPublishVersion;
    }
    
    self.privatePublishSettings = settings;
    
    return self.privatePublishSettings;
    
}

- (double) minutesBeforeNextFetchFromDate:(NSDate *)date {
    
    double currentTimeElapsed = [date timeIntervalSinceDate:self.lastFetch];
    
    double timeRemaining = self.publishSettings.minutesBetweenRefresh - currentTimeElapsed;
    
    return timeRemaining;
    
}

@end
