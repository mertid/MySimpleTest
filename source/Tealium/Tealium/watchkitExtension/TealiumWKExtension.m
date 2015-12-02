//
//  TealiumWK.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TealiumWKExtension.h"
#import "TEALBlocks.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"


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
    
    return [self newInstanceForKey:key configuration:configuration completion:nil];
    
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


//- (id<TealiumDelegate> _Nullable) delegate{
//    
//}
//
//
//- (void) setDelegate:(id<TealiumDelegate> _Nullable)delegate{
//    
//}


- (void) trackEventWithTitle:(NSString * _Nullable)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
}

- (void) trackViewWithTitle:(NSString * _Nullable)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
}


#pragma mark - Data Management


//- (NSDictionary * _Nonnull) volatileDataSourcesCopy{
//    
//}

- (void) addVolatileDataSources:(NSDictionary * _Nonnull)additionalDataSources{
    
}


- (void) removeVolatileDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys{
    
}


//- (NSDictionary * _Nonnull) persistentDataSourcesCopy{
//    
//}


- (void) addPersistentDataSources:(NSDictionary * _Nonnull)additionalDataSources{
    
}


- (void) removePersistentDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys{
    
}

#pragma mark - PRIVATE APIs

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALConfiguration *)configuration
                        completion:(TEALBooleanCompletionBlock)completion{

    BOOL success = NO;
    NSError *error = nil;
    
    configuration.instanceID = key;
    
    TealiumWKExtension *instance = [[TealiumWKExtension alloc] initPrivateInstanceWithConfiguration:configuration];
    
    if (!instance){
        
#warning Complete error handling
    
    }
    
    [self addInstance:instance key:key];
    
    if (completion) {
        completion(success, error);
    }
    
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
