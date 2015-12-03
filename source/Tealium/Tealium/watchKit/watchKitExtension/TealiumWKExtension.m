//
//  TealiumWK.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TealiumWKExtension.h"
#import "TEALBlocks.h"
#import "TEALError.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"
#import "TEALWatchKitConstants.h"

@import WatchConnectivity;

/**
 *  Multiton object like Tealium
 */
@interface TealiumWKExtension()

@property (nonatomic, strong) TEALConfiguration *configuration;
@property (nonatomic, strong) TEALOperationManager *operationManager;

@end

@implementation TealiumWKExtension

__strong static NSDictionary *staticAllInstances = nil;

#pragma mark - PUBLIC APIs

+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALConfiguration * _Nullable)configuration{
    
    
    // check WKConnectivity
    
    return [self newInstanceForKey:key configuration:configuration completion:^(BOOL success, NSError * _Nullable error) {
        
        if (error){
         
            NSLog(@"Error initializing instance %@: %@", key, error);
        
        }
        
    }];
    
}

+ (_Nullable instancetype) instanceForKey:(NSString * _Nonnull)key{
    
    TealiumWKExtension *instance = staticAllInstances[key];
    
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
    
    [[WCSession defaultSession] sendMessage:@{
                                              TEALWKCommandTrackEventKey:@{
                                                      TEALWKCommandTrackArgumentInstanceIDKey:self.configuration.instanceID,
                                                      TEALWKCommandTrackArgumentTitleKey:title,
                                                      TEALWKCommandTrackArgumentCustomDataKey:customDataSources}
                                              }
                               replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
        // TODO
        
    } errorHandler:^(NSError * _Nonnull error) {
        
        // TODO
        
    }];
    
        NSLog(@"%s event title: %@ \n customDataSources; %@", __FUNCTION__, title, customDataSources);
}

- (void) trackViewWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
        NSLog(@"%s view title: %@ \n customDataSources; %@", __FUNCTION__, title, customDataSources);
}



#pragma mark - PRIVATE APIs

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALConfiguration *)configuration
                        completion:(TEALBooleanCompletionBlock)completion{

    BOOL success = NO;
    NSError *error = nil;
    TealiumWKExtension *instance = nil;
    
    configuration.instanceID = key;
    
    if (![TEALConfiguration isValidConfiguration:configuration]){
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Could not initialize new TealiumWKExtension instance.", @"")
                                  reason:NSLocalizedString(@"Invalid Configuration passed to init method.", @"")
                              suggestion:NSLocalizedString(@"Check configuration.", @"")];
    }
    
    if (!error){
        
        instance = [[TealiumWKExtension alloc] initPrivateInstanceWithConfiguration:configuration];
    
    }
    
    if (!error){
        
        if (!instance){
            
            NSString *reason = [NSString stringWithFormat:@"Instance could not be started with given configuration: %@", configuration];
            
            error = [TEALError errorWithCode:TEALErrorCodeException
                                 description:NSLocalizedString(@"Could not initialize new TealiumWKExtension instance.", @"")
                                      reason:reason
                                  suggestion:NSLocalizedString(@"Check configuration.", @"")];
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

+ (void) addInstance:(TealiumWKExtension * _Nonnull)instance key:(NSString * _Nonnull)key {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    mDict[key] = instance;
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];
    
    staticAllInstances = newInstances;
}

- (instancetype) initPrivateInstanceWithConfiguration:(TEALConfiguration *)configuration {
    
    self = [super init];
    
    if (self) {
        _configuration = configuration;
        _operationManager   = [[TEALOperationManager alloc] initWithInstanceID:configuration.instanceID];
    }
    
    return self;
    
}

@end
