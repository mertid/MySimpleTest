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

@end

@implementation TEALSettings

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
    
    return true;
}

- (BOOL) autotrackingCarrierInfoEnabled {
    
    return true;
    
}

- (BOOL) autotrackingDeviceInfoEnabled {
    
    return true;
    
//    if ([self publishSettings].disableDeviceInfoAutotracking) return NO;
//    return self.configuration.autotrackingDeviceInfoEnabled;
}

- (BOOL) autotrackingIvarsEnabled {
        
    return false;
}

- (BOOL) autotrackingLifecycleEnabled {
    return false;
}

- (BOOL) autotrackingTimestampInfoEnabled {
    return true;
}

- (BOOL) autotrackingUIEventsEnabled {
    return false;
}

- (BOOL) autotrackingViewsEnabled {
    return false;
}

- (BOOL) autotrackingCrashesEnabled {
    return false;
}

- (BOOL) libraryShouldDisable {

    return ([self publishSettings].status == TEALPublishSettingsStatusDisable);
}

- (BOOL) mobileCompanionEnabled {
    return false;
}

- (BOOL) isValid {
    return ([TEALConfiguration isValidConfiguration:self.configuration] &&
            [self publishSettings].status != TEALPublishSettingsStatusDisable);
}

- (BOOL) wifiOnlySending {
    
    return [[self publishSettings] enableSendWifiOnly];
}

- (BOOL) goodBatteryLevelOnlySending {
    
    BOOL response = [[self publishSettings] enableLowBatterySuppress];
    
    return response;
}

- (BOOL) isDefaultPublishSettings {
    
    return ([self publishSettings].status == TEALPublishSettingsStatusDefault);
    
}

- (double) daysDispatchesValid {
    return [[self publishSettings] numberOfDaysDispatchesAreValid];
}

- (double) minutesBetweenRefresh {
    
    return [[self publishSettings] minutesBetweenRefresh];
    
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

- (NSString *) configurationDescription {
    return self.configuration.description;
}

- (NSString *) publishSettingsDescription {
    return [[self publishSettings] description];
}

- (NSString *) publishSettingsURLString {
    if (!self.mobilePublishSettingsURLString){
        
        self.mobilePublishSettingsURLString = [self.configuration publishSettingsURL];
    }
    return self.mobilePublishSettingsURLString;
}

- (NSString *) publishURLString {
    if (!self.tiqPublishURLString){
        self.tiqPublishURLString = [self.configuration publishSettingsURL];
    }
    return self.tiqPublishURLString;
}

- (NSUInteger) dispatchSize {
    return [self publishSettings].dispatchSize;
}

- (NSString *) logLevelString {
    
    NSString * logLevel = [[self publishSettings] overrideLogLevel];

    NSArray* words = [logLevel componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString* logLevelClean = [words componentsJoinedByString:@""];
    
    if (!logLevelClean ||
        [logLevelClean isEqualToString:@""]){
        
        logLevel = self.configuration.environmentName;

    }
    
    return logLevel;
    
}

- (NSUInteger) offlineDispatchQueueSize {
    return [[self publishSettings] offlineDispatchQueueSize];
}

- (NSURLRequest *) publishSettingsRequest {
    
    NSString *baseURL = [self.configuration publishSettingsURL];
    NSDictionary *params = @{}; //[self.configuration mobilePublishSettingsURLParams];
    NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
    NSString *settingsURLString = [baseURL stringByAppendingString:queryString];
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:settingsURLString];
    
    return request;
}

- (NSError *) prefetchErrorForRequest:(NSURLRequest *)request
                                 date:(NSDate *)date {
    
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
    
    double minutesToNextFetch = [self minutesBeforeNextFetchFromDate:date];
    
    if (!preFetchError &&
        minutesToNextFetch > 0.0) {
        
        NSString * reason = [NSString stringWithFormat:@"Can not fetch at this time - %f minutes to end of refresh timeout.", minutesToNextFetch];
        preFetchError = [TEALError errorWithCode:TEALErrorCodeFailure
                                     description:NSLocalizedString(@"Unable to fetch new publish settings", @"")
                                          reason:reason
                                      suggestion:NSLocalizedString(@"Wait for end of timeout or change prior minutes between refresh setting.", @"")];
        
    }
    
    if (!preFetchError &&
        !self.urlSessionManager){
        
        preFetchError = [TEALError errorWithCode:TEALErrorCodeException
                                     description:NSLocalizedString(@"Can not fetch at this time", @"")
                                          reason:NSLocalizedString(@"TEALURLSessionManager not yet assigned to settings", @"")
                                      suggestion:NSLocalizedString(@"Consult Tealium Mobile engineering", @"")];
        
    }
    
    return preFetchError;
}


- (void) fetchNewRawPublishSettingsWithCompletion:(TEALBooleanCompletionBlock)completion{
    
    NSURLRequest *request = [self publishSettingsRequest];
    NSDate *now = [NSDate date];
    
    NSError *preFetchError = [self prefetchErrorForRequest:request
                                                      date:now];
    
    if (preFetchError){
        if (completion){
            completion (NO, preFetchError);
        }
        return;
    }
    
    self.lastFetch = now;
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.urlSessionManager performRequest:request
                            withCompletion:^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
                             
                                                                
        NSError *error = nil;
                  
        NSDictionary *parsedData = nil;

        TEALPublishSettings *publishSettings = nil;
                      
        if (connectionError) {
            error = connectionError;
        }
                                
        if (!error &&
            [response respondsToSelector:@selector(statusCode)]){
            
            NSInteger statusCode = response.statusCode;
            
            if (statusCode != 200){
                
                NSString *reason = [NSString stringWithFormat:@"Unexpected response code recieved: %ld", (long)statusCode];
                
                error = [TEALError errorWithCode:TEALErrorCodeFailure
                                     description:NSLocalizedString(@"Failed to fetch new publish settings.", @"")
                                          reason:reason
                                      suggestion:NSLocalizedString(@"Make certain that the account-profile from TIQ has the Mobile Publish Settings enabled OR that the overridePublishURL configuration option is valid.", @"")];
                

                
            }
                                    
        }
                                
        if (!error){
            publishSettings = [weakSelf publishSettings];;
        }
          
        if (!error &&
            !parsedData){
            
            // Fallback to current mobile.html MPS var
            parsedData = [TEALPublishSettings mobilePublishSettingsFromHTMLData:data error:error];
            
        }
                                
        if (!error &&
            !parsedData){
            // For future MPS config location - currently ignoring any error from this
            parsedData = [TEALPublishSettings mobilePublishSettingsFromJSONFile:data error:nil];
        }
                                
                                
        if (!error &&
            !parsedData){
            
            error = [TEALError errorWithCode:TEALErrorCodeException
                                 description:NSLocalizedString(@"Failed to fetch new publish settings", @"")
                                      reason:NSLocalizedString(@"Unable to parse json or html data from request target", @"")
                                  suggestion:NSLocalizedString(@"Check account/profile or overridePublishSettingsURL", @"")];
            
        }
            
        NSDictionary *matchingPublishSettings = [publishSettings currentPublishSettingsFromRawPublishSettings:parsedData];
                                
        if (!error &&
            !matchingPublishSettings) {
            
            // No MPS Settings for current library version
            error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                 description:NSLocalizedString(@"No mobile publish settings for current library version found.", @"")
                                      reason:NSLocalizedString(@"Mobile Publish Settings for current version may not have been published.", @"")
                                  suggestion:NSLocalizedString(@"Activate the correct Mobile Publish Setting version in TIQ, re-publish, or update library.", @"")];
        }
        
                                
        if (!error &&
            !publishSettings){
            
            NSString *urlString = [self.configuration publishSettingsURL];
            
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
                                
        BOOL newPublishSettings = ![publishSettings isEqualToRawPublishSettings:matchingPublishSettings];

        if (newPublishSettings){

            [publishSettings updateWithMatchingVersionSettings:matchingPublishSettings];
            
        }
        
        // Return successful completion if new settings found
        if (completion) {
            completion( newPublishSettings, error);
        }
        
    }];
    
}

- (void) purgeAllArchives {
    
    [TEALPublishSettings purgeAllArchives];
}

#pragma mark - PRIVATE

- (TEALPublishSettings *) publishSettings {
    
    if (!self.privatePublishSettings){
        
        self.privatePublishSettings = [self newOrArchivedPublishedSettings];
    }
    
    return self.privatePublishSettings;
    
}

- (TEALPublishSettings *) newOrArchivedPublishedSettings {
    
    // Will load archive if available
    
    NSString *urlString = [self.configuration publishSettingsURL];
    
    TEALPublishSettings *archiveSettings = [TEALPublishSettings archivedPublishSettingForURL:urlString];
    
    if (archiveSettings){
        return archiveSettings;
    }
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:urlString];
    
//    settings.targetVersion = TEALDefaultPublishVersion;
    
    return settings;
    
}

- (double) minutesBeforeNextFetchFromDate:(NSDate *)date {
    
    double currentTimeElapsed = [date timeIntervalSinceDate:self.lastFetch];
    
    double timeRemaining = self.publishSettings.minutesBetweenRefresh - currentTimeElapsed;
    
    return timeRemaining;
    
}

- (NSString *) description {
    
    return [NSString stringWithFormat:@"%@%@", self.configuration, self.publishSettings];
    
}

@end
