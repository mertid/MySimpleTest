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
#import "TEALPublishSettings+Collect.h"


static NSString * defaultCollectDispatchURLString = nil;

static NSString * defaultLegacyS2SDispatchURLString = nil;

@implementation TEALSettings (Collect)

#pragma mark - PUBLIC

- (BOOL) collectEnabled {
    
    return [[self publishSettings] enableCollect];
    
}

- (BOOL) s2SLegacyEnabled {
    
    return [[self publishSettings] enableS2SLegacy];
}

- (NSString *) collectDispatchURLStringForVisitorID:(NSString *)visitorID {
    
    NSString *overrideDispatchString = [self.configuration overrideCollectDispatchURL];
        
    if (overrideDispatchString){
        
        return [self finalOverrideCollectDispatchURLStringFrom:overrideDispatchString
                                                     visitorID:visitorID];
        
    } else {
        
        return [TEALSettings defaultCollectDispatchURLStringFromConfiguration:self
                                                                    visitorID:visitorID];
    }
    
}

- (NSString *) finalOverrideCollectDispatchURLStringFrom:(NSString *)baseOverride
                                               visitorID:(NSString *)visitorID {

    NSDictionary *paramKeys = [TEALNetworkHelpers dictionaryFromUrlParamString:baseOverride];
    
    id existingVisitorVID = paramKeys[@"tealium_vid"];
    
    NSString *finalString = baseOverride;
    
    if (!existingVisitorVID){
        
        NSDictionary *appendData = @{@"tealium_vid":visitorID};
    
        finalString = [TEALNetworkHelpers appendUrlParamString:baseOverride withDictionary:appendData];

    }
    
    return finalString;
    
}

- (NSUInteger) collectPollingFrequency {
    return self.configuration.collectPollingFrequency;
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

#pragma mark - PRIVATE

+ (NSString *) defaultCollectDispatchURLStringFromConfiguration:(TEALSettings *)settings
                                                      visitorID:(NSString *)visitorID{
    
    if (!defaultCollectDispatchURLString){
        
        NSString *urlPrefix = @"https";
        
        NSString *baseURLString = [NSString stringWithFormat:@"%@://collect.tealiumiq.com/vdata/i.gif?", urlPrefix];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        
        
        params[TEALDataSourceKey_Tealium_Account]   = [settings account];
        params[TEALDataSourceKey_Tealium_Profile]   = [settings asProfile];
        params[TEALCollectKey_VisitorID] = visitorID;
        
        NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
        
        defaultCollectDispatchURLString = [baseURLString stringByAppendingString:queryString];
    }
    
    return defaultCollectDispatchURLString;
}


+ (NSString *) defaultS2SLegacyDispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
    if (!defaultLegacyS2SDispatchURLString){
        NSString *urlPrefix = @"https";
        
        NSString *account = [settings account];
        NSString *profile = [settings asProfile];
        NSString *queue = @"8"; // 2-AS Live Events, 8-Legacy S2S, 10-both
        
        NSString *baseURLString = [NSString stringWithFormat:@"%@://collect.tealiumiq.com/%@/%@/%@/i.gif?", urlPrefix, account, profile, queue];
        
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@//visitor-service.tealiumiq.com/datacloudprofiledefinitions/%@/%@",
                           urlPrefix,
                           [settings account],
                           [settings asProfile]];
    
    return [NSURL URLWithString:urlString];
}

@end
