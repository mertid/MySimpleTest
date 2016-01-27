//
//  Tealium+TagManagement+PrivateHeader.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/25/16.
//
//

#ifndef Tealium_TagManagement_PrivateHeader_h
#define Tealium_TagManagement_PrivateHeader_h


#endif /* Tealium_TagManagement_PrivateHeader_h */

#import "Tealium+TagManagement.h"
#import "TEALRemoteCommandManager.h"
#import "TEALTagDispatchService.h"

@interface Tealium (TagManagementPrivate)

- (TEALTagDispatchService *) currentTagDispatchService;

- (TEALRemoteCommandManager *) remoteCommandManager;

- (void) addRemoteCommandID:(NSString*)name
                description:(NSString*)description
                targetQueue:(dispatch_queue_t)queue
              responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                 completion:(TEALBooleanCompletionBlock)completion;

- (void) removeRemoteCommandID:(NSString *)commandID
                    completion:(TEALBooleanCompletionBlock)completion;

@end