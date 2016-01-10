//
//  TEALSettings+Collect.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALSettings+Collect.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALConfiguration+Collect.h"
#import "TEALDataSourceConstants.h"
#import "TEALNetworkHelpers.h"


static NSString * defaultCollectDispatchURLString = nil;

static NSString * defaultLegacyS2SDispatchURLString = nil;

@implementation TEALSettings (Collect)

#pragma mark - PUBLIC

- (BOOL) collectEnabled {
    
    return [self publishSettings].enableCollect;
    
}

- (BOOL) s2SLegacyEnabled {
    
    return [self publishSettings].enableS2SLegacy;
}

- (NSString *) collectDispatchURLStringForVisitorID:(NSString *)visitorID {
    
    NSString *overrideDispatchString = [self.configuration overrideCollectDispatchURL];
    
    if (overrideDispatchString){
        return overrideDispatchString;
    } else {
        return [TEALSettings defaultCollectDispatchURLStringFromConfiguration:self
                                                                    visitorID:visitorID];
    }
    
}

- (NSUInteger) collectPollingFrequency {
    return self.configuration.collectPollingFrequency;
}

- (NSString *) traceID {
    
    return [self.configuration traceID];
    
}


- (NSString *) s2SLegacyDispatchURLString {
    
    NSString *overrideDispatchString = self.configuration.overrideS2SLegacyDispatchURL;
    
    if (overrideDispatchString){
        return overrideDispatchString;
    } else {
        return [TEALSettings defaultS2SLegacyDispatchURLStringFromConfiguration:self];
    }
    
}

- (NSURL *) collectProfileURLForVisitorID:(NSString *)visitorID {
    
    return [TEALSettings defaultProfileURLFromSettings:self visitorID:visitorID];
    
}

- (NSURL *) collectProfileDefinitionsURL {
    
    return [TEALSettings defaultProfileDefinitionsURLFromSettings:self];
}

- (void) setTraceID:(NSString *)traceID {
    
    [self.configuration setTraceID:traceID];

}

#pragma mark - PRIVATE

+ (NSString *) defaultCollectDispatchURLStringFromConfiguration:(TEALSettings *)settings
                                                      visitorID:(NSString *)visitorID{
    
    if (!defaultCollectDispatchURLString){
        
        NSString *urlPrefix = @"https";
        
        if ([settings useHTTP]) {
            urlPrefix = @"http";
        }
        
        NSString *baseURLString = [NSString stringWithFormat:@"%@://datacloud.tealiumiq.com/vdata/i.gif?", urlPrefix];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        
        params[TEALCollectKey_Account]   = [settings account];
        params[TEALCollectKey_Profile]   = [settings asProfile];
        params[TEALCollectKey_VisitorID] = visitorID;
        
        if ([settings traceID]) {
            params[TEALCollectKey_TraceID] = [settings traceID];
        }
        
        NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
        
        defaultCollectDispatchURLString = [baseURLString stringByAppendingString:queryString];
    }
    
    return defaultCollectDispatchURLString;
}


+ (NSString *) defaultS2SLegacyDispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
    if (!defaultLegacyS2SDispatchURLString){
        NSString *urlPrefix = @"https";
        
        if ([settings useHTTP]) {
            urlPrefix = @"http";
        }
        
        NSString *account = [settings account];
        NSString *profile = [settings asProfile];
        NSString *queue = @"8"; // 2-AS Live Events, 8-Legacy S2S, 10-both
        
        NSString *baseURLString = [NSString stringWithFormat:@"%@://datacloud.tealiumiq.com/%@/%@/%@/i.gif?", urlPrefix, account, profile, queue];
        
        defaultLegacyS2SDispatchURLString = baseURLString;
    }
    
    return defaultLegacyS2SDispatchURLString;
    
}

+ (NSURL *) defaultProfileURLFromSettings:(TEALSettings *)settings
                                visitorID:(NSString *)visitorID{
    
    if (![settings isValid]) {
        return nil;
    }
    
    NSString *urlPrefix = @"https:";
    
    if ([settings useHTTP]) {
        urlPrefix = @"http:";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@//visitor-service.tealiumiq.com/%@/%@/%@",
                           urlPrefix,
                           settings.account,
                           settings.asProfile,
                           visitorID];
    
    return [NSURL URLWithString:urlString];
}

+ (NSURL *) defaultProfileDefinitionsURLFromSettings:(TEALSettings *)settings {
    
    if (![settings isValid]) {
        return nil;
    }
    
    NSString *urlPrefix = @"https:";
    
    if ([settings useHTTP]) {
        urlPrefix = @"http:";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@//visitor-service.tealiumiq.com/datacloudprofiledefinitions/%@/%@",
                           urlPrefix,
                           [settings account],
                           [settings asProfile]];
    
    return [NSURL URLWithString:urlString];
}

@end
