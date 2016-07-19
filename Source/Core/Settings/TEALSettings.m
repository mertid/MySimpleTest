//
//  TEALSettings.m
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Composite of Configurations and Publish Settings (new, default or archived)

#import "TEALSettings.h"
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
    
}

- (BOOL) autotrackingIvarsEnabled {
        
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

    BOOL disable = [[self publishSettings] disableLibrary];
    
    return disable;
    
}

- (BOOL) mobileCompanionEnabled {
    return false;
}

- (BOOL) isValid {
    return ([TEALConfiguration isValidConfiguration:self.configuration] &&
            [self publishSettings]);
}

- (BOOL) wifiOnlySending {
    
    return [[self publishSettings] enableSendWifiOnly];
}

- (BOOL) goodBatteryLevelOnlySending {
    
    BOOL response = [[self publishSettings] enableLowBatterySuppress];
    
    return response;
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

//- (NSString *) cacheBuster {
//    
//    NSUInteger random = arc4random_uniform(100);
//    
//    NSString *randomString = [NSString stringWithFormat:@"%lu", (unsigned long)random];
//    
//    return randomString;
//    
//}

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
    
    double minutesToNextFetch = [self minutesBeforeNextFetchFromDate:date
                                                             timeout:self.publishSettings.minutesBetweenRefresh];
    
    if (!preFetchError &&
        minutesToNextFetch > 0.0) {
        
        NSString * reason = [NSString stringWithFormat:@"Can not fetch at this time: %f minutes to end of refresh timeout.", minutesToNextFetch];
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

- (NSError *) urlRequestErrorFor:(NSHTTPURLResponse *)response
                            data:(NSData *)data
                 connectionError:(NSError *)connectionError {
    
    
    if (connectionError) {
        
        return connectionError;
        
    }
    
    NSError *error = nil;

    if ([response respondsToSelector:@selector(statusCode)]){
        
        NSInteger statusCode = response.statusCode;
        
        if (statusCode != 200){
            
            NSString *reason = [NSString stringWithFormat:@"Unexpected response code recieved: %ld", (long)statusCode];
            
            error = [TEALError errorWithCode:TEALErrorCodeFailure
                                 description:NSLocalizedString(@"Failed to fetch new publish settings.", @"")
                                      reason:reason
                                  suggestion:NSLocalizedString(@"Make certain that the account-profile from TIQ has the Mobile Publish Settings enabled OR that the overridePublishURL configuration option is valid.", @"")];
            
        }
        
    }
    
    return error;

}

- (NSDictionary *) matchingPublishSettingsFromData:(NSData *)data
                                             error:(NSError * __autoreleasing *)error {
    
    NSDictionary *parsedData = nil;
    
    // Extract all publish settings data from source data
    
    parsedData = [TEALPublishSettings mobilePublishSettingsFromHTMLData:data error:error];
    
    if (!parsedData){
        // For future MPS config location
        parsedData = [TEALPublishSettings mobilePublishSettingsFromJSONFile:data error:error];
    }
    
    if (!parsedData){
        
        *error = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"No mobile publish settings for current library version found.", @"")
                                  reason:NSLocalizedString(@"Mobile Publish Settings for current version may not have been published.", @"")
                              suggestion:NSLocalizedString(@"Activate the correct Mobile Publish Setting version in TIQ, re-publish, or update library.", @"")];
        
        return nil;
        
    }
    
    // Extract only the publish settings matching the current library veresion
    
    NSDictionary *matchingPublishSettings = [TEALPublishSettings currentPublishSettingsFromRawPublishSettings:parsedData];
    
    return matchingPublishSettings;
    
}

- (void) fetchNewRawPublishSettingsWithURLParameters:(NSDictionary *)parameters
                                          completion:(void (^)(BOOL, NSError * _Nullable))completion {
    
    
    
    NSURLRequest *request = [self.configuration publishSettingsRequestWithParams:parameters];
    
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
                             
        // Request OK?
        NSError *requestError = [weakSelf urlRequestErrorFor:response
                                                        data:data
                                             connectionError:connectionError];
        if (requestError){
            if (completion){
                completion(NO, requestError);
            }
            return;
        }
                                
        // Get publish settings matching this library version
        NSError *error = nil;
        NSDictionary *publishData = [weakSelf matchingPublishSettingsFromData:data
                                                                        error:&error];
        if (!publishData){
            if (completion){
                completion(NO, error);
            }
            return;
        }
                            
        //  Is publish settings ready to process?
        TEALPublishSettings *publishSettings = [self publishSettings];
                                
        if (!publishSettings){
            
            NSString *errorReaseon = [NSString stringWithFormat:@"Could not init publish settings with configuration: %@", self.configuration];
            
            NSError *error = [TEALError errorWithCode:TEALErrorCodeException
                                          description:NSLocalizedString(@"Unable to update Publish Settings.", @"")
                                               reason:errorReaseon
                                           suggestion:NSLocalizedString(@"Check override publish setting.", @"")];
            
            if (completion){
                completion(NO, error);
            }
            return;
        }
              
        // Are remote publish settings new?
        BOOL newPublishSettings = ![publishSettings isEqualToRawPublishSettings:publishData];
        
        if (!newPublishSettings){
            // Remote publish setting same as what's loaded / existing
            if (completion){
                completion(NO, nil);
            }
            return;
        }
        
        // Yay! We have new settings
        [publishSettings updateWithMatchingVersionSettings:publishData];
            
        if (completion){
            completion(YES, nil);
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
    
    NSString *urlString = [self.configuration basePublishSettingsURL];
    
    TEALPublishSettings *archiveSettings = [TEALPublishSettings archivedPublishSettingForURL:urlString];
    
    if (archiveSettings){
        return archiveSettings;
    }
    
    TEALPublishSettings *settings = [[TEALPublishSettings alloc] initWithURLString:urlString];
    
    return settings;
    
}


- (double) minutesBeforeNextFetchFromDate:(NSDate *)date
                                  timeout:(double)timeout {
    
    if (!self.lastFetch){
        return 0.0;
    }
    
    double currentTimeElapsed = [date timeIntervalSinceDate:self.lastFetch];
    
    double currentTimeElapsedInMinutes = currentTimeElapsed / 60;
    
    double timeRemaining =  timeout - currentTimeElapsedInMinutes;
    
    return timeRemaining;
    
}

//- (double) minutesBeforeNextFetchFromDate:(NSDate *)date {
//    
//    if (!self.lastFetch){
//        return 0.0;
//    }
//    
//    double currentTimeElapsed = [date timeIntervalSinceDate:self.lastFetch];
//    
//    double currentTimeElapsedInMinutes = currentTimeElapsed / 60;
//    
//    double timeRemaining =  self.publishSettings.minutesBetweenRefresh - currentTimeElapsedInMinutes;
//    
//    return timeRemaining;
//    
//}

- (NSString *) description {
    
    return [NSString stringWithFormat:@"%@%@", self.configuration, self.publishSettings];
    
}

@end
