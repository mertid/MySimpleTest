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
#import "TEALPublishSettings.h"
#import "TEALURLSessionManager.h"

@interface TEALSettings()

@property (nonatomic, strong) TEALConfiguration *configuration;
@property (nonatomic, strong) TEALPublishSettings *publishSettings;

@end

@implementation TEALSettings

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
        
        self.publishSettings.status = TEALPublishSettingsStatusInvalid;
        
        completion( nil, error );
        return;
    }
    
    TEALHTTPResponseBlock requestCompletion = ^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {
            
            completion( NO, connectionError);
            
            return;
        }
        
        NSError *parseError = nil;
        NSDictionary *parsedData = [self mobilePublishSettingsFromHTMLData:data
                                                                     error:&parseError];
        
        if (parsedData) {
            [self.publishSettings updateWithRawSettings:parsedData];
            completion( YES, nil);
        } else {
            self.publishSettings.status = TEALPublishSettingsStatusInvalid;
            completion( NO, parseError );
        }
        
    };
    
    if (!self.urlSessionManager) {
        TEAL_LogNormal(@"Missing urlSessionManager");
    }
    
    [self.urlSessionManager performRequest:request
                            withCompletion:requestCompletion];
    
    
}

- (void) loadArchivedSettings {
    [self.publishSettings loadArchived];
}


- (BOOL) isValid {
    return ([TEALConfiguration validConfiguration:self.configuration] && self.publishSettings.status != TEALPublishSettingsStatusInvalid);
}
    
- (BOOL) lifecycleEnabled {
    return self.configuration.lifecycleEnabled;
}

- (BOOL) tagManagementEnabled {
    return self.configuration.tagManagementEnabled;
}

- (BOOL) audienceStreamEnabled {
    return self.configuration.audienceStreamEnabled;
}

- (BOOL) autotrackingUIEventsEnabled {
    return self.configuration.autotrackingUIEventsEnabled;
}

- (BOOL) autotrackingViewsEnabled {
    return self.configuration.autotrackingViewsEnabled;
}

- (BOOL) useHTTP {
    return self.configuration.useHTTP;
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

- (NSString *) overridePublishSettingsURL {
    return self.configuration.overridePublishSettingsURL;
}

- (NSString *) overridePublishURL {
    return self.configuration.overridePublishURL;
}

- (NSString *) publishSettingsDescription {
    return self.publishSettings.description;
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
