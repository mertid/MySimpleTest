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

- (NSString *) collectDispatchURLString {
    
    NSString *overrideDispatchString = [self.configuration overrideCollectDispatchURL];
    
    if (overrideDispatchString){
        return overrideDispatchString;
    } else {
        return [TEALSettings defaultCollectDispatchURLStringFromConfiguration:self];
    }
    
}

- (NSUInteger) pollingFrequency {
    return self.configuration.pollingFrequency;
}


- (NSString *) s2SLegacyDispatchURLString {
    
    NSString *overrideDispatchString = self.configuration.overrideS2SLegacyDispatchURL;
    
    if (overrideDispatchString){
        return overrideDispatchString;
    } else {
        return [TEALSettings defaultS2SLegacyDispatchURLStringFromConfiguration:self];
    }
    
}

#pragma mark - PRIVATE

+ (NSString *) defaultCollectDispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
    if (!defaultCollectDispatchURLString){
        
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

@end
