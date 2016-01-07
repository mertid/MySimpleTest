//
//  TealiumWK.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtension.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataQueue.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"
#import "TEALError.h"

@import WatchConnectivity;
@import WatchKit;

// Local declaration so we don't need a dependency to TEALBlocks.h
typedef void (^SuccessBlock)(BOOL success, NSError *error);

//NSString * const TEALWKTimestampOverrideKey = @"timestamp_unix";

/**
 *  Multiton object to support multiple instances of Tealium
 */
@interface TEALWKExtension()

@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALWKExtensionConfiguration *configuration;
@property TEALDataQueue *queue;
@property TEALLogger *logger;
@property TEALOperationManager *operationManager;

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

- (void) destroy {
    
    [TEALWKExtension destroyInstanceForKey:self.instanceID];
    
}

- (void) trackEventWithTitle:(NSString * _Nonnull)title
                 dataSources:(NSDictionary * _Nullable)customDataSources{
    
    [self trackEventWithTitle:title
                  dataSources:customDataSources
                   completion:nil];
    
}

- (void) trackViewWithTitle:(NSString * _Nonnull)title
                dataSources:(NSDictionary * _Nullable)customDataSources{
    
    [self trackViewWithTitle:title
                  dataSources:customDataSources
                   completion:nil];
    
}


#pragma mark - PRIVATE / INTERNAL APIs

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALWKExtensionConfiguration *)configuration
                        completion:(void(^)(BOOL success, NSError *error))completion{

    
    // Bail out early if possible
    if (![WCSession isSupported]){
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                      description:NSLocalizedString(@"Initialization failed.", @"")
                                           reason:NSLocalizedString(@"WCSession not supported on this device", @"")
                                       suggestion:NSLocalizedString(@"Using the Tealium extension on this device will not be possible.", @"")];
        
        if (completion) {
            completion(FALSE, error);
        }
        return nil;
    }
    
    TEALWKExtension *instance = [[TEALWKExtension alloc] initPrivateInstanceWithInstanceID:key
                                                            configuration:configuration];
    
    if (!instance){
        
        NSString *reason = [NSString stringWithFormat:@"Instance could not be started with given configuration: %@", configuration];
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Could not init extension library", @"")
                                  reason:reason
                              suggestion:NSLocalizedString(@"Check coniguration.", @"")];
        
        if (completion) {
            completion(instance, error);
        }
        
        return nil;
    }
    
    
    [instance.logger logQA:[configuration description]];
    
    [instance.logger logQA:[instance description]];
    
    [self addInstance:instance key:key];
    
    if (completion) {
        completion(instance, nil);
    }
            
    return instance;
    
}

+ (void) addInstance:(TEALWKExtension * _Nonnull)instance key:(NSString * _Nonnull)key {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    mDict[key] = instance;
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];
    
    staticAllInstances = newInstances;
    
}

- (instancetype) initPrivateInstanceWithInstanceID:(NSString *)instanceID
                                     configuration:(TEALWKExtensionConfiguration *)configuration {
    
    self = [super init];
    
    if (self) {
        _configuration = configuration;
        _logger = [[TEALLogger alloc] initWithInstanceID:instanceID];
        _instanceID = instanceID;
        _operationManager   = [[TEALOperationManager alloc] initWithInstanceID:instanceID];
        _queue = [TEALDataQueue queueWithCapacity:100];
    }
    
    return self;
    
}

- (BOOL) isReachable {
    
    WCSession *session = [WCSession defaultSession];
    
    return session.reachable;
    
}

- (NSDictionary *) packagePayloadFromType:(NSString *)type
                                    title:(NSString *)title
                              dataSources:(NSDictionary *)customDataSources {
    
    
    NSMutableDictionary *expandedCustomDataSources = [NSMutableDictionary dictionary];
    
    if (!customDataSources) customDataSources = @{};

    [expandedCustomDataSources addEntriesFromDictionary:customDataSources];
    
    [expandedCustomDataSources addEntriesFromDictionary:[self timestampOverrideDataSources]];
    
    [expandedCustomDataSources addEntriesFromDictionary:[self wasQueueOverrideDataSources]];

    NSDictionary *payloadDataSources = [NSDictionary dictionaryWithDictionary:expandedCustomDataSources];
    
    NSDictionary * payload = @{
                               TEALWKCommandTrackKey:@{
                                       TEALWKCommandTrackArgumentTypeKey:type,
                                       TEALWKCommandTrackArgumentInstanceIDKey:self.instanceID,
                                       TEALWKCommandTrackArgumentTitleKey:title,
                                       TEALWKCommandTrackArgumentCustomDataKey:payloadDataSources}
                               };
    
    return payload;
    
}

- (void) trackEventWithTitle:(NSString * _Nonnull)title
                 dataSources:(NSDictionary * _Nullable)customDataSources
                  completion:(SuccessBlock)completion {
    
    // Completion failure = no sent, could be queued or error occurred
    
    if (!self.instanceID){ return; }
    
    NSString * trackType = TEALWKCommandTrackValueEvent;
    
    NSDictionary *payload = [self packagePayloadFromType:trackType
                                                   title:title
                                             dataSources:customDataSources];
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        
        [weakSelf trackWithMessagePayload:payload completion:completion];
        
    }];
    
}

- (void) trackViewWithTitle:(NSString * _Nonnull)title
                dataSources:(NSDictionary * _Nullable)customDataSources
                 completion:(SuccessBlock)completion {
    
    if (!self.instanceID){ return; }
    
    NSString * trackType = TEALWKCommandTrackValueView;
    
    NSDictionary *payload = [self packagePayloadFromType:trackType
                                                   title:title
                                             dataSources:customDataSources];
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        
        [weakSelf trackWithMessagePayload:payload completion:completion];
        
    }];
    
    
}
- (void) trackWithMessagePayload:(NSDictionary *)payload
                      completion:(SuccessBlock)completion{
    
#warning Todo more optimal way to check and log reachability
    
    NSString *wasQueued = payload[TEALDataSourceKey_WasQueued];
    
    if ([TEALDataSourceValue_True isEqualToString:wasQueued]){
        
        [self reportUnreachable:payload];
        
        return;
    }
    
    [self.queue enqueueObject:payload];
    
    if (![self isReachable]){
        
        if (completion){
            completion(false, nil);
        }
        
        return;
    }
    
    // Only returns once the payload is actually sent or lost
    [self sendQueueWithTriggerPayload:payload
                      completionBlock:completion];
        

    
}

- (void) reportUnreachable:(NSDictionary *) payload {
    
    NSString *message = [NSString stringWithFormat:@"Host application not reachable. Saving queued calls: %@", [self.queue allQueuedObjects]];
    
    [self.logger logDev:message];
    
}

- (NSDictionary *) wasQueueOverrideDataSources {
    
    NSString *wasQueued = TEALDataSourceValue_False;
    
    if (![self isReachable]){
        wasQueued = TEALDataSourceValue_True;
    }
    
    return @{TEALDataSourceKey_WasQueued:wasQueued};
}

- (NSDictionary *) timestampOverrideDataSources{
    
    // Adds timestamp unix to the data sources which will override the
    // timestamp calculations on the host app's Tealium library instance
    
    return @{TEALDataSourceKey_TimestampUnix: [self timestampNowAsString]};
    
}

- (NSString *) timestampNowAsString {
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    
    NSString *intervalString = [NSString stringWithFormat:@"%f", interval];
    
    return intervalString;
    
}

- (void) sendQueueWithTriggerPayload:(NSDictionary *)targetPayload
                     completionBlock:(SuccessBlock)completion {
    
    for (NSDictionary *payload in [[self.queue allQueuedObjects] copy]){
        
        [self.queue dequeueFirstObject];
        
        if ([payload isEqualToDictionary:targetPayload]){
            
            [self sendPayload:payload completion:completion];
        
        } else {
        
            [self sendPayload:payload completion:nil];
        
        }
    
    }
    
}

- (void) sendPayload:(NSDictionary *)payload
          completion:(SuccessBlock)completion {
    
    __block typeof(self) __weak weakSelf = self;
    
    [[WCSession defaultSession] sendMessage:payload
           replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
               
               
               [weakSelf.logger logQA:[NSString stringWithFormat:@"Track message sent to host app: %@ reply: %@", payload, replyMessage]];
            
               if (completion){
                   completion(TRUE, nil);
               }
           
       } errorHandler:^(NSError * _Nonnull error) {
           
           [weakSelf.logger logQA:[NSString stringWithFormat:@"Error with track message to host app: %@: error: %@", payload, error]];
           
           // Requeue if there was a problem
           [self.queue enqueueObjectToFirstPosition:payload];
           
           if (completion){
               completion(FALSE, error);
           }
           
       }];
    
}

- (NSString *) description {
    
    NSString *title = @"Tealium Watch Kit Extension";
    
    NSString *instanceID = self.instanceID? self.instanceID : @"(unknown)";
    
    NSDictionary *descriptionData = @{
                                      @"instance ID": instanceID,
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
