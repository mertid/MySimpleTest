//
//  TEALConfiguration.m
//  Tealium Mobile Library
//
//  Created by George Webster on 3/2/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALConfiguration.h"
#import "NSString+Tealium.h"
#import "TEALNetworkHelpers.h"

@interface TEALConfiguration()

// Hidden
@property (nonatomic) BOOL autotrackingApplicationInfoEnabled;
@property (nonatomic) BOOL autotrackingCarrierInfoEnabled;
@property (nonatomic) BOOL autotrackingTimestampInfoEnabled;
@property (nonatomic) NSString *privateInstanceID;
@property (nonatomic) NSMutableDictionary *privateModuleData;
@property (nonatomic) NSMutableDictionary *privateModuleDescriptionData;
@property (nonatomic) dispatch_queue_t queue;


// v5.1
@property (nonatomic) BOOL autotrackingCrashesEnabled;
@property (nonatomic) BOOL autotrackingDeviceInfoEnabled;
@property (nonatomic) BOOL autotrackingIvarsEnabled;
@property (nonatomic) BOOL autotrackingLifecycleEnabled;
@property (nonatomic) BOOL autotrackingUIEventsEnabled;
@property (nonatomic) BOOL autotrackingViewsEnabled;
@property (nonatomic) BOOL mobileCompanionEnabled;

@end

@implementation TEALConfiguration

#pragma mark - PUBLIC CLASS

+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName{
    
    TEALConfiguration *configuration = [[TEALConfiguration alloc] init];
    
    // Default configuration
    configuration.accountName       = [accountName lowercaseString];
    configuration.profileName       = [profileName lowercaseString];
    configuration.environmentName   = [environmentName lowercaseString];
    configuration.autotrackingApplicationInfoEnabled = YES;
    configuration.autotrackingCarrierInfoEnabled = YES;
    configuration.autotrackingDeviceInfoEnabled = YES;
    configuration.autotrackingIvarsEnabled = NO;
    configuration.autotrackingLifecycleEnabled  = YES;
    configuration.autotrackingTimestampInfoEnabled = YES;
    configuration.autotrackingUIEventsEnabled = NO;
    configuration.autotrackingViewsEnabled = YES;
    configuration.autotrackingCrashesEnabled = YES;
    configuration.mobileCompanionEnabled = YES;
    configuration.overridePublishSettingsURL = nil;
    configuration.overrideTagManagementURL = nil;
    
    [configuration queue];
    
    return configuration;
}

+ (BOOL) isValidConfiguration:(TEALConfiguration *)configuration {
    if (!configuration.accountName) return NO;
    if (!configuration.profileName) return NO;
    if (!configuration.environmentName) return NO;
    
    NSString *accountSpacesRemoved = [configuration.accountName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([accountSpacesRemoved isEqualToString:@""]) return NO;
    
    NSString *profileSpacesRemoved = [configuration.profileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([profileSpacesRemoved isEqualToString:@""]) return NO;
    
    NSString *environmentSpacesRemoved = [configuration.environmentName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([environmentSpacesRemoved isEqualToString:@""]) return NO;
    
    return YES;
}

#pragma mark - PUBLIC INSTANCE

- (NSString * _Nonnull)instanceID {
    
    if (!self.privateInstanceID){
        self.privateInstanceID = [NSString stringWithFormat:@"%@.%@.%@", self.accountName, self.profileName, self.environmentName];
    }
    return self.privateInstanceID;
    
}

- (NSURLRequest *) publishSettingsRequestWithParams:(NSDictionary *)params {
    
    NSString *requestString = nil;
    
    if (self.overridePublishSettingsURL) {
        
        requestString = self.overridePublishSettingsURL;
        
    } else {
        
        NSString *baseDefault = [self defaultPublishSettingsURL];
        
        NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
        
        requestString = [baseDefault stringByAppendingString:queryString];
        
    }

    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:requestString];
    
    return request;
}


#pragma mark - MODULE DATA
- (NSMutableDictionary *) moduleData {
    
    if (!self.privateModuleData){
        self.privateModuleData = [NSMutableDictionary new];
    }
    
    return self.privateModuleData;
    
}

- (id) moduleObjectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync([self processingQueue], ^{
        obj = [self moduleData][key];
    });
    
    return obj;
}

- (void) setModuleObject:(id<NSCopying, NSSecureCoding>)object
                  forKey:(id<NSCopying, NSSecureCoding>)aKey
              completion:(void(^)(BOOL successful, NSError *error))completion {
    
    dispatch_barrier_async([self processingQueue], ^{
        
        [self moduleData][aKey] = object;
        
        if (completion){
            completion(true, nil);
        }
    });
}

- (void) removeModuleObjectForKey:(id<NSCopying, NSSecureCoding>)aKey
                       completion:(void(^)(BOOL successful, NSError *error))completion{
    
    dispatch_barrier_async([self processingQueue], ^{
        
        [[self moduleData] removeObjectForKey:aKey];
        
        if (completion){
            completion(true, nil);
        }
        
    });
}

- (NSMutableDictionary *) moduleDescriptionData {
    
    if (!self.privateModuleDescriptionData) {
        self.privateModuleDescriptionData = [NSMutableDictionary new];
    }
    
    return self.privateModuleDescriptionData;
}

- (void) setModuleDescription:(NSString *) description
                  forKey:(NSString *)aKey {
    
    dispatch_barrier_async([self processingQueue], ^{
    
        [self moduleDescriptionData][aKey] = description;
        
    });
}

- (void) removeModuleDescriptionForKey:(id<NSCopying, NSSecureCoding>)aKey {
    
    dispatch_barrier_async([self processingQueue], ^{
        
        [[self moduleDescriptionData] removeObjectForKey:aKey];
        
    });
}

#pragma mark - PRIVATE CLASS

- (dispatch_queue_t) processingQueue {
    
    if (!self.queue){
        NSString *fullQueueName = [NSString stringWithFormat:@"tealium.configuration.queue.%@.%@.%@", self.accountName, self.profileName, self.environmentName];
        const char * queueName = [fullQueueName UTF8String];
        self.queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self.queue;
}

//+ (NSString *) publishSettingsURLFromConfiguration:(TEALConfiguration *)configuration {
//    
//    if (configuration.overridePublishSettingsURL) {
//        return configuration.overridePublishSettingsURL;
//    }
//    
//    // Default
//    NSString *urlPrefix = @"https:";
//    
//    return [NSString stringWithFormat:@"%@//tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?",
//            urlPrefix,
//            configuration.accountName,
//            configuration.profileName,
//            configuration.environmentName];
//}

- (NSString *) basePublishSettingsURL {
    
    if (self.overridePublishSettingsURL){
        return self.overridePublishSettingsURL;
    }
    
    return [self defaultPublishSettingsURL];
    
}

- (NSString *) defaultPublishSettingsURL{
    
    NSString *urlString = [NSString stringWithFormat:@"https://tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?",
            self.accountName,
            self.profileName,
            self.environmentName];
    
    return urlString;
    
}

#pragma mark - PRIVATE INSTANCE

//- (NSString *) publishSettingsURL {
//    
//    return [TEALConfiguration publishSettingsURLFromConfiguration:self];
//    
//}


- (NSDictionary *) baseDescriptionData {
    
    return @{
              @"instance id":[NSString teal_dictionarySafeString:self.instanceID],
              @"account - name":[NSString teal_dictionarySafeString:self.accountName],
              @"account - profile":[NSString teal_dictionarySafeString:self.profileName],
              @"account - target environment":[NSString teal_dictionarySafeString:self.environmentName],
              @"override publish settings url":[NSString teal_dictionarySafeString:self.overridePublishSettingsURL],
              @"override publish url":[NSString teal_dictionarySafeString:self.overrideTagManagementURL],
              
              };
    
}

- (NSDictionary *) finalDescriptionData {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[self baseDescriptionData]];
    
    [mDict addEntriesFromDictionary:[self moduleDescriptionData]];
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

- (NSString *) description {
    
    NSDictionary *descriptionData = [self finalDescriptionData];
    
    return [NSString teal_descriptionForObject:self description:@"Compile time options" fromDictionary:descriptionData];
    
}
@end
