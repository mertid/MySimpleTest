//
//  Tealium+TagManagement+PrivateHeader.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/25/16.
//
//

#import "Tealium+TagManagement.h"
#import "TEALRemoteCommandManager.h"
#import "TEALTagDispatchService.h"

@interface Tealium (TagManagementPrivate)

- (TEALTagDispatchService *) currentTagDispatchService;

- (TEALTagDispatchService *) newTagDispatchService;

- (TEALRemoteCommandManager *) remoteCommandManager;

- (void) addRemoteCommandID:(NSString*)name
                description:(NSString*)description
                targetQueue:(dispatch_queue_t)queue
              responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                 completion:(TEALBooleanCompletionBlock)completion;

- (void) removeRemoteCommandID:(NSString *)commandID
                    completion:(TEALBooleanCompletionBlock)completion;

@end