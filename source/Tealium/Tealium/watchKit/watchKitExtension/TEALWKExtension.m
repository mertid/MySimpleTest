//
//  TealiumWK.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtension.h"
//#import "TEALWKExtensionQueue.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataQueue.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"

@import WatchConnectivity;
@import WatchKit;

NSString * const TEALWKTimestampOverrideKey = @"timestamp_unix";

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
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
       
        [TEALWKExtension destroyInstanceForKey:weakSelf.instanceID];
        
    }];
    
}

- (void) trackEventWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
    if (!self.instanceID){ return; }

    NSString * trackType = TEALWKCommandTrackValueEvent;
    
    NSDictionary *payload = [self packagePayloadFromType:trackType
                                                  title:title
                                            dataSources:customDataSources];
    
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        
        [weakSelf trackWithMessagePayload:payload];

    }];
    
}

- (void) trackViewWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources{
    
    if (!self.instanceID){ return; }

    NSString * trackType = TEALWKCommandTrackValueView;
    
    NSDictionary *payload = [self packagePayloadFromType:trackType
                                                   title:title
                                             dataSources:customDataSources];
    
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
      
        [weakSelf trackWithMessagePayload:payload];
        
    }];

    
}


#pragma mark - PRIVATE / INTERNAL APIs

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALWKExtensionConfiguration *)configuration
                        completion:(void(^)(BOOL success, NSError *error))completion{

    
    
    TEALWKExtension *instance = nil;
    
    instance = [[TEALWKExtension alloc] initPrivateInstanceWithInstanceID:key
                                                            configuration:configuration];
    
//    __block __weak TEALWKExtension *weakInstance = instance;
//    [instance.operationManager addOperationWithBlock:^{
    
        NSError *error = nil;

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
            
            [instance.logger logQA:[configuration description]];
            
            [instance.logger logQA:[instance description]];
            
            [self addInstance:instance key:key];
            
        }
        
        if (completion) {
            completion(instance, error);
        }
        
//    }];
    
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

- (void) trackWithMessagePayload:(NSDictionary *)payload{
    
#warning Todo more optimal way to check and log reachability
    
    NSString *wasQueued = payload[TEALDataSourceKey_WasQueued];
    
    if ([TEALDataSourceValue_True isEqualToString:wasQueued]){
        
        [self reportUnreachable:payload];
        
        return;
    }
    
    [self.queue enqueueObject:payload];
    
    [self sendQueue];
    
}

- (void) reportUnreachable:(NSDictionary *) payload {
    
    NSString *message = [NSString stringWithFormat:@"Host application not reachable. Saving queued calls: %@", [self.queue allQueuedObjects]];
    
    [self.logger logDev:message];
    
    if (self.delegate) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

        [self.delegate tealiumExtensionDidQueueTrackCall:payload[TEALWKCommandTrackKey] currentQueueCount:[self.queue count]];

        });
    
    }
    
}

- (NSDictionary *) wasQueueOverrideDataSources {
    
    NSString *wasQueued = TEALDataSourceValue_False;
    
    if (![[WCSession defaultSession] isReachable]){
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

- (void) sendQueue {
    
    for (NSDictionary *payload in [[self.queue allQueuedObjects] copy]){
        
        [self.queue dequeueFirstObject];
        
        [self sendPayload:payload];
    
    }
    
}

- (void) sendPayload:(NSDictionary *)payload {
    
    __block typeof(self) __weak weakSelf = self;
    
    [[WCSession defaultSession] sendMessage:payload
           replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
               
               
               [weakSelf.logger logQA:[NSString stringWithFormat:@"Track message sent to host app: %@ reply: %@", payload, replyMessage]];
               
               if (weakSelf.delegate){
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       [weakSelf.delegate tealiumExtensionDidHandoffTrackCall:payload[TEALWKCommandTrackKey]];

                   });
               }
            
           
       } errorHandler:^(NSError * _Nonnull error) {
           
           [weakSelf.logger logQA:[NSString stringWithFormat:@"Error with track message to host app: %@: error: %@", payload, error]];
           
           if (weakSelf.delegate){
               
               dispatch_async(dispatch_get_main_queue(), ^{

               [weakSelf.delegate tealiumExtensionTrackCall:payload[TEALWKCommandTrackKey] didEncounterError:error];
               
               });
           }
           
#warning Possibility of enqueue and deque happening out of order from sendQueue command?
           
           // Requeue if there was a problem
           [self.queue enqueueObjectToFirstPosition:payload];
           
       }];
    
}

- (NSString *) description {
    
    NSString *title = @"Tealium Watch Kit Extension";
    
    NSString *instanceID = self.instanceID? self.instanceID : @"(unknown)";
    
    NSString *delegate = self.delegate? [self.delegate description] : @"(none assigned)";
    
    NSDictionary *descriptionData = @{
                                      @"instance ID": instanceID,
                                      @"delegate" : delegate
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
