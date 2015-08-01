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
#import "TEALLogger.h"
#import "TEALConfiguration.h"
#import "TEALURLSessionManager.h"
#import "TEALDatasources.h"

@interface TEALSettings()

@property (nonatomic, strong) TEALConfiguration *configuration;
@property (nonatomic, strong) TEALPublishSettings *publishSettings;
@property (nonatomic, strong) NSString *audienceStreamDispatchURLString;
@property (nonatomic, strong) NSString *mobilePublishSettingsURLString;
@property (nonatomic, strong) NSString *tiqPublishURLString;
@property (nonatomic, strong) NSString *visitorID;
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

- (BOOL) autotrackingUIEventsEnabled {
    return self.configuration.autotrackingUIEventsEnabled;
}

- (BOOL) autotrackingViewsEnabled {
    return self.configuration.autotrackingViewsEnabled;
}

- (BOOL) isValid {
    return ([TEALConfiguration validConfiguration:self.configuration] && self.publishSettings.status != TEALPublishSettingsStatusDisable);
}
    
- (BOOL) lifecycleEnabled {
    return self.configuration.lifecycleEnabled;
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

- (NSString *) dispatchURLString {
    if (!self.audienceStreamDispatchURLString) {
        self.audienceStreamDispatchURLString = [TEALSettings dispatchURLStringFromConfiguration:self];
    }
    return self.audienceStreamDispatchURLString;
}

- (NSString *) publishSettingsDescription {
    return self.publishSettings.description;
}

//- (NSString *) overridePublishSettingsURL {
//    return self.configuration.overridePublishSettingsURL;
//}
//
//- (NSString *) overridePublishURL {
//    return self.configuration.overridePublishURL;
//}

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

- (NSString *) visitorIDCopy {
    if (!self.visitorID) {
        return @"";
    }
    return [self.visitorID copy];
}

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
    
    [self.urlSessionManager performRequest:request
                            withCompletion:^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
                                
                                if (connectionError) {
                                    
                                    [weakSelf.publishSettings loadArchived];
                                    if (completion) completion( weakSelf.publishSettings.status, connectionError);
                                    
                                    return;
                                }
                                
                                NSError *parseError = nil;
                                NSDictionary *parsedData = [weakSelf mobilePublishSettingsFromHTMLData:data
                                                                                                 error:&parseError];
                                
                                if (parsedData) {
                                    [weakSelf.publishSettings updateWithRawSettings:parsedData];
                                    if (completion) completion( weakSelf.publishSettings.status, nil);
                                } else {
                                    [weakSelf.publishSettings loadArchived];
                                    if (completion) completion( weakSelf.publishSettings.status, parseError );
                                }
                                
                                
                            }];
    
    
}

- (void) loadArchivedSettings {
    [self.publishSettings loadArchived];
}

- (void) setVisitorIDCopy:(NSString *)visitorID {
    
    self.visitorID = visitorID;
}

#pragma mark - PRIVATE METHODS

- (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError **)error {
    
    NSDictionary *resultDictionary = nil;
    
    NSString *dataString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    
    NSError *regexError = nil;
    
    NSString *scriptContentsPattern = @"<script.+>.+</script>";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:scriptContentsPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regexError];
    if (!regex) {
        *error = regexError;
        return nil;
    }
    
    __block NSString *scriptContents = nil;
    
    [regex enumerateMatchesInString:dataString
                            options:NSMatchingReportCompletion
                              range:NSMakeRange(0, dataString.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             if (result) {
                                 TEAL_LogExtreamVerbosity(@"text checking result: %@", result);
                             }
                             
                             if (result.range.location != NSNotFound) {
                                 scriptContents = [dataString substringWithRange:result.range];
                                 
                                 if (scriptContents) {
                                     TEAL_LogExtreamVerbosity(@"scriptContents: %@", scriptContents);
                                 }
                                 
                                 *stop = YES;
                             }
                         }];
    
    if (!scriptContents) {
        
        return nil;
    }
    
    NSRange mpsRangeStart = [scriptContents rangeOfString:@"var mps = "
                                                  options:NSCaseInsensitiveSearch
                                                    range:NSMakeRange(0, scriptContents.length)];
    
    if (mpsRangeStart.location == NSNotFound) {
        
        TEAL_LogVerbose(@"mobile publish settings not found! old mobile library extension is not supported.  ");
        
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                              description:@"Mobile publish settings not found."
                                   reason:@"Mobile publish settings not found. While parsing mobile.html"
                               suggestion:@"Please enable mobile publish settings in Tealium iQ."];
        
        return nil;
    }
    
    NSUInteger startIndex = NSMaxRange( mpsRangeStart );
    NSUInteger endLength = scriptContents.length - startIndex;
    NSRange mpsRangeEnd = [scriptContents rangeOfString:@"</script>"
                                                options:NSCaseInsensitiveSearch
                                                  range:NSMakeRange(startIndex, endLength)];
    
    if (mpsRangeEnd.location == NSNotFound) {
        return nil;
    }
    
    NSRange mpsRange = NSMakeRange(startIndex, ( mpsRangeEnd.location - startIndex ) );
    
    NSString *mpsDataString = [scriptContents substringWithRange:mpsRange];
    
    TEAL_LogExtreamVerbosity(@"mpsDataString: %@", mpsDataString);
    
    // TODO: check for missing utag and / or tags
    
    NSData *mpsJSONData = [mpsDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError = nil;
    
    resultDictionary = [NSJSONSerialization JSONObjectWithData:mpsJSONData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&jsonError];
    
    if (!resultDictionary) {
        *error = jsonError;
        return nil;
    }
    
    return resultDictionary;
}


@end
