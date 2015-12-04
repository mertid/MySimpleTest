//
//  TealiumWK.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtension.h"
#import "TEALWKConstants.h"


typedef NS_ENUM(NSUInteger, TEALWKLogLevel){
    /**
     *  Nothing is logged to the console, this is the default.
     */
    TEALWKLogLevelNone = 0,
    /**
     *  Only errors reported.
     */
    TEALWKLogLevelProd,
    /**
     *  Provides warnings and errors only.
     */
    TEALWKLogLevelQA,
    /**
     *  Most verbose - Useful for debugging and verification during development.
     */
    TEALWKLogLevelDev
    
    
};


@import WatchConnectivity;

/**
 *  Multiton object to support multiple instances of Tealium
 */
@interface TEALWKExtension()

@property (nonatomic, strong) TEALWKExtensionConfiguration *configuration;

@end

@implementation TEALWKExtension

__strong static NSDictionary *staticAllInstances = nil;

#pragma mark - PUBLIC APIs

+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALWKExtensionConfiguration * _Nullable)configuration{
    
    
    // check WKConnectivity
    
    return [self newInstanceForKey:key configuration:configuration completion:^(BOOL success, NSError * _Nullable error) {
        
        if (error){
         
            NSLog(@"Tealium Watch Kit: Error initializing instance %@: %@", key, error);
        
        }
        
    }];
    
}

+ (_Nullable instancetype) instanceForKey:(NSString * _Nonnull)key{
    
    TEALWKExtension *instance = staticAllInstances[key];
    
    return instance;
    
}

+ (void) destroyInstanceForKey:(NSString * _Nonnull)key{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    
    [mDict removeObjectForKey:key];
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];
    
    staticAllInstances = newInstances;
    
    
}


- (void) trackEventWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
    if (!customDataSources) customDataSources = @{};
    
    __block typeof(self) __weak weakSelf = self;

    [[WCSession defaultSession] sendMessage:@{
                                              TEALWKCommandTrackEventKey:@{
                                                      TEALWKCommandTrackArgumentInstanceIDKey:self.configuration.instanceID,
                                                      TEALWKCommandTrackArgumentTitleKey:title,
                                                      TEALWKCommandTrackArgumentCustomDataKey:customDataSources}
                                              }
       replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
           [weakSelf logMessage:[NSString stringWithFormat:@"Track view titled: %@: %@", title, replyMessage] level:TEALWKLogLevelQA];
           
       } errorHandler:^(NSError * _Nonnull error) {
           
           [weakSelf logMessage:[NSString stringWithFormat:@"Error Tracking view titled: %@: %@", title, error] level:TEALWKLogLevelQA];
        
    }];
    
        NSLog(@"%s event title: %@ \n customDataSources; %@", __FUNCTION__, title, customDataSources);
}

- (void) trackViewWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
    if (!customDataSources) customDataSources = @{};
    
    __block typeof(self) __weak weakSelf = self;

    [[WCSession defaultSession] sendMessage:@{
                                              TEALWKCommandTrackViewKey:@{
                                                      TEALWKCommandTrackArgumentInstanceIDKey:self.configuration.instanceID,
                                                      TEALWKCommandTrackArgumentTitleKey:title,
                                                      TEALWKCommandTrackArgumentCustomDataKey:customDataSources}
                                              }
       replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
           
           [weakSelf logMessage:[NSString stringWithFormat:@"Track view titled: %@: %@", title, replyMessage] level:TEALWKLogLevelQA];
           
       } errorHandler:^(NSError * _Nonnull error) {
    
           [weakSelf logMessage:[NSString stringWithFormat:@"Error Tracking view titled: %@:%@", title, error] level:TEALWKLogLevelQA];
           
       }];
    
}



#pragma mark - PRIVATE / INTERNAL APIs

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALWKExtensionConfiguration *)configuration
                        completion:(void(^)(BOOL success, NSError *error))completion{

    BOOL success = NO;
    NSError *error = nil;
    TEALWKExtension *instance = nil;
    
    configuration.instanceID = key;
    
    if (![TEALWKExtensionConfiguration isValidConfiguration:configuration]){
        
        NSDictionary *errorInfo = @{
                                    NSLocalizedDescriptionKey: NSLocalizedString(@"Could not initialize new TEALWKExtension instance.", @""),
                                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid Configuration passed to init method.", @""),
                                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check configuration.", @"")
                                    };
        
        error = [NSError errorWithDomain:@"com.tealium.watchkit.error"
                                    code:400
                                userInfo:errorInfo];
    
    }
    
    if (!error){
        
        instance = [[TEALWKExtension alloc] initPrivateInstanceWithConfiguration:configuration];
    
    }
    
    if (!error){
        
        if (!instance){
            
            NSString *reason = [NSString stringWithFormat:@"Instance could not be started with given configuration: %@", configuration];

            NSDictionary *errorInfo = @{
                                        NSLocalizedDescriptionKey: NSLocalizedString(@"Could not initialize new TEALWKExtension instance.", @""),
                                        NSLocalizedFailureReasonErrorKey: reason,
                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check configuration.", @"")
                                        };
            
            error = [NSError errorWithDomain:@"com.tealium.watchkit.error"
                                        code:400
                                    userInfo:errorInfo];
            
        } else {
            
            success = YES;
            
        }
    }
    
    if (completion) {
        completion(success, error);
    }
    
    [self addInstance:instance key:key];

    return instance;
    
}

+ (void) addInstance:(TEALWKExtension * _Nonnull)instance key:(NSString * _Nonnull)key {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    mDict[key] = instance;
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];
    
    staticAllInstances = newInstances;
    
}

- (instancetype) initPrivateInstanceWithConfiguration:(TEALWKExtensionConfiguration *)configuration {
    
    self = [super init];
    
    if (self) {
        _configuration = configuration;
    }
    
    return self;
    
}

- (void) logMessage:(NSString *)message level:(TEALWKLogLevel)level {
    
    TEALWKLogLevel currentLevel = [self currentLogLevel];
    
    if (level <= currentLevel){
            NSLog(@"Tealium Watch Kit: %s: %@", __FUNCTION__, message);
    }
    
}


- (TEALWKLogLevel) currentLogLevel{
    
    NSString *log = self.configuration.environmentName;
    
    if ([@"dev" isEqualToString:[log lowercaseString]]){
        return TEALWKLogLevelDev;
    }
    if ([@"qa" isEqualToString:[log lowercaseString]]){
        return  TEALWKLogLevelQA;
    }
    if ([@"prod" isEqualToString:[log lowercaseString]]){
        return TEALWKLogLevelProd;
    }
    return TEALWKLogLevelNone;
    
}

@end
