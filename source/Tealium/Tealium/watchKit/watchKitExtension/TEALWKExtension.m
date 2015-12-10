//
//  TealiumWK.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtension.h"
#import "TEALWKExtensionQueue.h"

@import WatchConnectivity;
@import WatchKit;

NSString * const TEALWKTimestampOverrideKey = @"timestamp_unix";

/**
 *  Multiton object to support multiple instances of Tealium
 */
@interface TEALWKExtension()

@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALWKExtensionConfiguration *configuration;
@property (nonatomic, strong) TEALWKExtensionQueue *queue;

@end

@implementation TEALWKExtension

__strong static NSDictionary *staticAllInstances = nil;

#pragma mark - PUBLIC APIs

+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALWKExtensionConfiguration * _Nonnull)configuration{
    
    return [self newInstanceForKey:key configuration:configuration completion:^(BOOL success, NSError * _Nullable error) {
        
        if (error){
         
            NSLog(@"%s: Error initializing instance %@: %@", __FUNCTION__, key, error);
        
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
    
    if (!self.instanceID){ return; }

    NSString * trackType = TEALWKCommandTrackValueEvent;
    
    NSDictionary *payload = [self packagePayloadFromType:trackType
                                                  title:title
                                            dataSources:customDataSources];
    
    [self trackWithMessagePayload:payload];
    
}

- (void) trackViewWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
    if (!self.instanceID){ return; }

    NSString * trackType = TEALWKCommandTrackValueView;
    
    NSDictionary *payload = [self packagePayloadFromType:trackType
                                                   title:title
                                             dataSources:customDataSources];
    
    [self trackWithMessagePayload:payload];
    
}


#pragma mark - PRIVATE / INTERNAL APIs

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALWKExtensionConfiguration *)configuration
                        completion:(void(^)(BOOL success, NSError *error))completion{

    NSError *error = nil;
    TEALWKExtension *instance = nil;
    
    instance = [[TEALWKExtension alloc] initPrivateInstanceWithConfiguration:configuration];
    
    [instance setInstanceID:key];
    
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
    
        [instance logMessage:[configuration description] level:TEALWKLogLevelQA];

        [instance logMessage:[self description] level:TEALWKLogLevelQA];
        
        [self addInstance:instance key:key];
    
    }

    if (completion) {
        completion(instance, error);
    }
    
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
        _queue = [[TEALWKExtensionQueue alloc] init];
    }
    
    return self;
    
}

- (void) logMessage:(NSString *)message level:(TEALWKLogLevel)level {
    
    TEALWKLogLevel currentLevel = [self currentLogLevel];
    
    if (level <= currentLevel){
            NSLog(@"%@", message);
    }
    
}


- (TEALWKLogLevel) currentLogLevel{
    
    return self.configuration.logLevel;
    
}


- (BOOL) isReachable {
    
    WCSession *session = [WCSession defaultSession];
    
    return session.reachable;
    
}

- (NSDictionary *) packagePayloadFromType:(NSString *)type
                                    title:(NSString *)title
                              dataSources:(NSDictionary *)customDataSources {
    
    if (!customDataSources) customDataSources = @{};
    
    NSDictionary * expandedCustomDataSources = [self customDataSourcesWithTimestamp:customDataSources];
    
    NSDictionary * payload = @{
                               TEALWKCommandTrackKey:@{
                                       TEALWKCommandTrackTypeKey:type,
                                       TEALWKCommandTrackArgumentInstanceIDKey:self.instanceID,
                                       TEALWKCommandTrackArgumentTitleKey:title,
                                       TEALWKCommandTrackArgumentCustomDataKey:expandedCustomDataSources}
                               };
    
    return payload;
    
}

- (void) trackWithMessagePayload:(NSDictionary *)payload{
    
    [self.queue queueCallPayload:payload];
    
    if (![self isReachable]){
        
        NSString *message = [NSString stringWithFormat:@"Host application not reachable. Saving queued calls: %@", self.queue.currentQueue];
        
        [self logMessage:message level:TEALWKLogLevelDev];
                
        if (self.delegate) {
            [self.delegate tealiumExtensionDidQueueTrackCall:payload[TEALWKCommandTrackKey] currentQueueCount:[[self.queue currentQueue] count]];
        }
        
        return;
    }
    
    [self sendQueue];
    
}

- (NSDictionary *) customDataSourcesWithTimestamp:(NSDictionary *)dataSources{
    
    // Adds timestamp unix to the data sources which will override the
    // timestamp calculations on the host app's Tealium library instance
    
    NSMutableDictionary *newDataSources = [NSMutableDictionary dictionary];
    
    [newDataSources addEntriesFromDictionary:dataSources];
    
    newDataSources[TEALWKTimestampOverrideKey] = [self timestampNowAsString];
    
    return [NSDictionary dictionaryWithDictionary:newDataSources];
    
}

- (NSString *) timestampNowAsString {
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    
    NSString *intervalString = [NSString stringWithFormat:@"%f", interval];
    
    return intervalString;
    
}

- (void) sendQueue {
    
    for (NSDictionary *payload in [self.queue currentQueue]){
        
        [self sendPayload:payload];
    
        // Iterating through a copy so we can safely remove calls as we process them
        [self.queue removeFirstCall];
    }
    
}

- (void) sendPayload:(NSDictionary *)payload {
    
    __block typeof(self) __weak weakSelf = self;
    
    [[WCSession defaultSession] sendMessage:payload
           replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
               
                   [weakSelf logMessage:[NSString stringWithFormat:@"Track message sent to host app: %@ reply: %@", payload, replyMessage]
                                  level:TEALWKLogLevelQA];
                   
                   if (weakSelf.delegate){
                       
                       [weakSelf.delegate tealiumExtensionDidHandoffTrackCall:payload[TEALWKCommandTrackKey]];
                   }
               
               
           } errorHandler:^(NSError * _Nonnull error) {
               
               
               [weakSelf logMessage:[NSString stringWithFormat:@"Error with track message to host app: %@: error: %@", payload, error]
                              level:TEALWKLogLevelQA];
               
               if (weakSelf.delegate){
                   
                   [weakSelf.delegate tealiumExtensionTrackCall:payload[TEALWKCommandTrackKey] didEncounterError:error];
                   
               }
               
               // Requeue if there was a problem
               [self.queue queueCallPayload:payload];
               
               
           }];
    
}

- (NSString *) description {
    
    NSString *title = @"Tealium Watch Kit Extension";
    
    NSString *instanceID = self.instanceID? self.instanceID : @"(unknown)";
    
    NSDictionary *descriptionData = @{
                                      @"instance ID": instanceID
                                      };
    
    
    NSString *displayClass              = NSStringFromClass([self class]);
    
    NSMutableString *descriptionString = [NSMutableString stringWithString:[NSString stringWithFormat:@"\r\r === %@ === \r", displayClass]];
    
    if (title){
        [descriptionString appendString:[NSString stringWithFormat:@"( %@ )\r", title]];
    }
    
    NSArray *keys = [[descriptionData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in keys){
        NSString *keyValue = descriptionData[key];
        if (keyValue) {
            [descriptionString appendString:[NSString stringWithFormat:@"%@:%@ \r", key, keyValue]];
        }
    }
    
    [descriptionString appendString:@"\r"];
    
    return [NSString stringWithString:descriptionString];
    
}

@end
