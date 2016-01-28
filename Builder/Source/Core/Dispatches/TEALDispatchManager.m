//
//  TEALDispatchManager.m
//  TealiumUtilities
//
//  Created by George Webster on 1/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import "TEALDispatchManager.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALBlocks.h"
#import "TEALError.h"

static NSString * const Tealium_DispatchQueueKey = @"com.tealium.dispatch_queue";
static NSString * const TEALIODispatchBaseQueueName = @"com.tealium.dispatch.ioqueue";

@interface TEALDispatchManager ()

@property NSUInteger privateQueueCapacity;
@property (atomic, strong) NSMutableArray *privateDispatchesQueued;
@property (nonatomic, weak) id<TEALDispatchManagerDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property BOOL isEnabled;

@end

@implementation TEALDispatchManager


#pragma mark - PUBLIC CLASS

+ (instancetype) dispatchManagerWithInstanceID:(NSString * _Nonnull) instanceID
                                      delegate:(id<TEALDispatchManagerDelegate>)delegate {
    
    return [[[self class] alloc] initWithInstanceID: instanceID
                                           delegate:delegate];
}

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString * _Nonnull)instanceID
                           delegate:(id<TEALDispatchManagerDelegate>)delegate {
    
    self = [self init];
    
    if (self) {
        
        _delegate           = delegate;
        
        NSString *fullQueueName = [NSString stringWithFormat:@"%@.%@", TEALIODispatchBaseQueueName , instanceID];
        const char * ioQueueName = [fullQueueName UTF8String];
        
        _ioQueue            = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_SERIAL);
        
        _privateQueueCapacity = 100;
                
        _isEnabled = YES;
        
    }
    
    return self;
}

- (void) addDispatch:(TEALDispatch *)dispatch
     completionBlock:(TEALDispatchBlock)completionBlock {
    
    if (!self.isEnabled){
        if (completionBlock){
            NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                          description:NSLocalizedString(@"Could not add dispatch.", @"")
                                               reason:NSLocalizedString(@"Dispatch Manager is disabled.", @"")
                                           suggestion:NSLocalizedString(@"Re-enable dispatch manager.", @"")];
            completionBlock(TEALDispatchStatusDestroyed, dispatch, error);
        }
        return;
    }
    
    @synchronized(self) {
        
        dispatch.assignedBlock = completionBlock;
        
        NSMutableArray *dispatches = [self dispatchesQueued];
        
        [self autoAdjustQueueSize:dispatches];
        
        [dispatches addObject:dispatch];
        
        [self runDispatches:dispatches];
        
    }
    
}

- (void) autoAdjustQueueSize:(NSMutableArray*)queue {
    
    // Resize to match capacity
    long diff = queue.count - self.privateQueueCapacity;
    
    if (diff > 0) {
        
        NSRange range;
        range.location = 0;
        range.length = diff;
        
        [queue removeObjectsInRange:range];
        
    }
    
}

- (void) disable {
    
    self.isEnabled = NO;
    
}

- (void) enable {
    
    self.isEnabled = YES;
}

- (void) purgeQueuedDispatches {
    
    [[self dispatchesQueued] removeAllObjects];
    
}

- (void) runQueuedDispatches {
    
    [self runDispatches:[self dispatchesQueued]];
    
}

- (void) updateQueuedCapacity:(NSUInteger)capacity {
    
    self.privateQueueCapacity = capacity;
    
}

- (NSArray *) queuedDispatches {
    
    return [NSArray arrayWithArray:[self dispatchesQueued]];
    
}

#pragma mark - PRIVATE

- (void) beginProcessingDispatches:(NSArray *)dispatches {
    
    NSArray *processingArray = [NSArray arrayWithArray:dispatches];
    
    NSMutableArray *successfullySentArray = [NSMutableArray array];
    
    for (TEALDispatch *dispatch in processingArray) {
        
        if ([self sendToDispatchServices:dispatch]){
            
            [successfullySentArray addObject:dispatch];
            
        }
        
    }
    
    [self removeDispatches:successfullySentArray];
    
}

- (BOOL) sendToDispatchServices:(TEALDispatch*)dispatch{
    
    if ([self.delegate dispatchManagerShouldPurgeDispatch:dispatch]){
        NSError *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                      description:NSLocalizedString(@"Dispatch purged", @"")
                                           reason:NSLocalizedString(@"Dispatch lifetime exceeded expiration threshold.", @"")
                                       suggestion:NSLocalizedString(@"See Publish Settings for dispatch expiration.", @"")];
        dispatch.assignedBlock(TEALDispatchStatusDestroyed, dispatch, error);
        // Dispatch will be deleted by processing method
        return YES;
        
    }
    if ([self.delegate dispatchManagerShouldDestroyDispatch:dispatch]){
        NSError *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                      description:NSLocalizedString(@"Dispatch destroyed", @"")
                                           reason:NSLocalizedString(@"Requested from delegate method.", @"")
                                       suggestion:NSLocalizedString(@"See implementation of tealium:shouldDropDispatch", @"")];
        dispatch.assignedBlock(TEALDispatchStatusDestroyed, dispatch, error);
        // Dispatch will be deleted by processing method
        return YES;
    }
    
    if ([self.delegate dispatchManagerShouldQueueDispatch:dispatch]){
        NSError *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                      description:NSLocalizedString(@"Dispatch queued", @"")
                                           reason:NSLocalizedString(@"Requested from delegate method.", @"")
                                       suggestion:NSLocalizedString(@"See implementation of tealium:shouldQueueDispatch", @"")];
        dispatch.assignedBlock(TEALDispatchStatusDestroyed, dispatch, error);
        // Will keep this dispatch in queue
        return NO;
    }
    
    [self.delegate dispatchManager:self
                  requestsDispatch:dispatch
                   completionBlock:dispatch.assignedBlock];
    
    return YES;
    
}

- (void) removeDispatches:(NSArray *)dispatches {
    
    @synchronized(self) {
        
        [[self dispatchesQueued] removeObjectsInArray:dispatches];
        
    }
    
}

- (void) runDispatches:(NSArray*)dispatches {
    
    if ([self.delegate dispatchManagerShouldDispatch:nil]){
        
        [self beginProcessingDispatches:dispatches];
        
    } else {
        
        [self saveDispatches:dispatches];
        
    }
}

- (void) saveDispatches:(NSArray *)dispatches {
    
    NSMutableArray *dataObjects = [NSMutableArray arrayWithCapacity:dispatches.count];
    
    for (id<NSCoding> obj in dispatches) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        [dataObjects addObject:data];
    }
    
    dispatch_async(self.ioQueue, ^{
        
        [[NSUserDefaults standardUserDefaults] setObject:dataObjects
                                                  forKey:Tealium_DispatchQueueKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    });
    
}

- (NSMutableArray*) savedDispatches {
    
    NSMutableArray *archivedDispatches = [[NSUserDefaults standardUserDefaults] objectForKey:Tealium_DispatchQueueKey];

    NSMutableArray *loadedDispatches = [[NSMutableArray alloc] initWithCapacity:self.privateQueueCapacity];

    for (id obj in archivedDispatches) {

        TEALDispatch *dispatch = nil;

        if ([obj isKindOfClass:[NSData class]]) {

            dispatch = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        }

        if (dispatch) {
            [loadedDispatches addObject:dispatch];
        }
    }

    return loadedDispatches;

}

- (NSMutableArray *) dispatchesQueued {
    
    if (!self.privateDispatchesQueued){
        self.privateDispatchesQueued = [self savedDispatches];
    }
    
    return self.privateDispatchesQueued;
    
}

@end
