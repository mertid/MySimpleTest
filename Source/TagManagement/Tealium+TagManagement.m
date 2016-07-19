//
//  Tealium+TagManagement.m
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//


#import "NSArray+Tealium.h"
#import "NSString+Tealium.h"
#import <objc/runtime.h>
#import "Tealium+TagManagement.h"
#import "Tealium+PrivateHeader.h"
#import "TEALModulesDelegate.h"
#import "TEALNetworkHelpers.h"
#import "TEALTagDispatchService.h"
#import "TEALRemoteCommandConstants.h"
#import "TEALRemoteCommandManager.h"
#import "TEALSettings+TagManagement.h"
#import "TEALError.h"

@interface Tealium() <TEALTagDispatchServiceDelegate, TEALRemoteCommandManagerDelegate>

@end

@implementation Tealium (TagManagement)

#pragma mark - PUBLIC INSTANCE

- (UIWebView *) webView {
    
    TEALTagDispatchService *currentService = [self currentTagDispatchService];
    
    return currentService.webView;
    
}

- (void) addRemoteCommandID:(NSString*)commandID
                description:(NSString*)description
                targetQueue:(dispatch_queue_t)queue
              responseBlock:(TEALRemoteCommandResponseBlock)responseBlock {
    
    __block typeof(self) __weak weakSelf = self;
    
    [self addRemoteCommandID:commandID
                 description:description
                 targetQueue:queue
               responseBlock:responseBlock
                  completion:^(BOOL success, NSError * _Nullable error) {
                      
                      if (success){
                          [weakSelf.logger logQA:@"Added remote command for id: %@", commandID];
                      }
                      if (error){
                          [weakSelf.logger logQA:@"Error adding remote command block %@: %@", commandID, error];
                      }
                  }];

}

- (void) removeRemoteCommandID:(NSString * _Nonnull)commandID {
    
    __block typeof(self) __weak weakSelf = self;

    [self removeRemoteCommandID:commandID
                     completion:^(BOOL success, NSError * _Nullable error) {
                         
                         [weakSelf.logger logDev:@"Remove command id %@ - %@ %@", commandID, success, error];

                     }];
    
}


#pragma mark - PRIVATE INSTANCE

- (void) updateTagManagement {
    
    if (![self.settings libraryShouldDisable] &&
        [self.settings tagManagementEnabled]){
        
        [self enableTagManagement];
        
        if ([self.settings remoteCommandsEnabled]){
            
            [self enableRemoteCommands];
            
        } else {
            
            [self disableRemoteCommands];
            
        }
        
    } else {
        [self disableTagManagement];
        [self disableRemoteCommands];
    }
    
}

- (void) enableTagManagement {

    TEALTagDispatchService *tagService = [self currentTagDispatchService];
    
    if (!tagService){
        
        tagService = [self newTagDispatchService];
        
        [self addNewDispatchService:tagService];
    }

}

- (void) enableRemoteCommands {

    NSUInteger commandCount = [[[self remoteCommandManager] commands] count];
    
    // Remote commands already in play
    if (commandCount > 0){
        return;
    }
    
    __block typeof(self) __weak weakSelf = self;
    
    [[self remoteCommandManager] addReservedCommands:^(BOOL successful) {
        
        if (successful) {
            
            [weakSelf.logger logDev:@"Reserved Remote Commands enabled."];
            
        }
    }];
    
    [self.logger logDev:@"Remote Commands enabled."];

    
}

- (void) disableTagManagement {
    
    TEALTagDispatchService *service = [self currentTagDispatchService];
    
    if (service){
        [self removeDispatchService:service];
    }
}

- (void) disableRemoteCommands {
    
    if (!privateRemoteCommandManager){
        return;
    }
    
    [[self remoteCommandManager] removeAllCommands];
    
}

- (void) addRemoteCommandID:(NSString*)name
                description:(NSString*)description
                targetQueue:(dispatch_queue_t)queue
              responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                 completion:(TEALBooleanCompletionBlock)completion {
    
    
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        
        TEALRemoteCommandManager *manager = [weakSelf remoteCommandManager];
        
        if (!manager){
            if (completion){
                NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                     description:NSLocalizedString(@"Could not add remote command.", @"")
                                          reason:NSLocalizedString(@"Remote Command Manager did not start.", @"")
                                      suggestion:NSLocalizedString(@"Consult Tealium Engineering - addRemoteCommandID:description:targetQueue:responseBlock:completion:", @"")];
                completion(NO, error);
                return;
            }
        }
        
        [manager addRemoteCommandID:name
                        description:description
                        targetQueue:queue
                      responseBlock:responseBlock
                         completion:completion];
        
    }];
    
    
}

- (void) removeRemoteCommandID:(NSString *)commandID
                    completion:(TEALBooleanCompletionBlock)completion {


    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        
        if (![weakSelf.settings tagManagementEnabled]){
            NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                 description:NSLocalizedString(@"Could not remove command block.", @"")
                                      reason:NSLocalizedString(@"Tag Management not enabled.", @"")
                                  suggestion:NSLocalizedString(@"Try call again later & Check that Tag Management is enabled in TIQ Publis Settings.", @"")];
            if (completion) {
                completion(NO, error);
            }
            return;
        }
        
        TEALRemoteCommandManager *remoteCommandManager = [weakSelf remoteCommandManager];

        [remoteCommandManager removeRemoteCommandID:commandID
                                         completion:completion];
        
    }];
    
}

#pragma mark - HELPERS

- (TEALTagDispatchService *) currentTagDispatchService {
    
    __block TEALTagDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [self currentDispatchServices];
    
    if (dispatchServices) {
        
        [dispatchServices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (![obj isMemberOfClass:([TEALTagDispatchService class])]){
                return;
            }
            
            TEALTagDispatchService *aService = obj;
            if ([aService.publishURLStringCopy isEqualToString:[self.settings tagManagementPublishURLString]]){
                targetService = aService;
                *stop = YES;
            }
            
        }];
    }
    
    return targetService;
}

- (TEALTagDispatchService *) newTagDispatchService {
    
    TEALTagDispatchService *tagService = [[TEALTagDispatchService alloc] initWithPublishURLString:[self.settings tagManagementPublishURLString] operationManager:self.operationManager];
    
    [tagService setDelegate:self];
    
    [tagService setup];
    
    return tagService;

}

static TEALRemoteCommandManager *privateRemoteCommandManager;

- (TEALRemoteCommandManager *) remoteCommandManager {
    
    if (!privateRemoteCommandManager){
        privateRemoteCommandManager = [[TEALRemoteCommandManager alloc] initWithOperationManager:self.operationManager];
        [privateRemoteCommandManager setDelegate:self];
    }
    
    return privateRemoteCommandManager;
}

#pragma mark - REMOTE COMMAND MANAGER DELEGATE

- (void) tagRemoteCommandManagerRequestsCommandToWebView:(NSString *)command {
    
    __block typeof(self) __weak weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *init = [weakSelf.webView stringByEvaluatingJavaScriptFromString:command];
        
        if ([[init lowercaseString] isEqualToString:@"false"]){
            
            NSString *errorDescription = [NSString stringWithFormat:@"Could not process callback command: %@", command];
            NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                          description:errorDescription
                                               reason:NSLocalizedString(@"Command did not execute.", @"")
                                           suggestion:NSLocalizedString(@"Check command id in TIQ", @"")];
            
            [weakSelf.logger logDev:@"Error executing Tag Bridge Command: %@", error];
        }
    });
}

#pragma mark - TEAL TAG DISPATCH SERVICE DELEGATE

- (BOOL) tagDispatchServiceShouldPermitRequest:(NSURLRequest *)request
                                       webView:(id)webView{
    
    NSError *error = nil;

    NSString *urlString = request.URL.absoluteString;
    
    __block NSString *commandString = [TEALRemoteCommandManager commandStringFromURLString:urlString
                                                                                     error:error];
    
    // URL request not a tagbridge request
    if (!commandString){
        return YES;
    }
    
    // URL request was meant for tagbridge, but formatting error detected
    if (error){
        [self.logger logQA:@"Remote command processing error: %@", error];
        return NO;
    }
    
    // Execute and report
    __block typeof(self) __weak weakSelf = self;

    [self.remoteCommandManager processCommandString:commandString
                                      responseBlock:^(TEALRemoteCommandResponse *response) {
                                      
          [weakSelf.logger logQA:@"Processed command: %@", response.commandId];
          [weakSelf.logger logDev:@"Response: %@", response];

      } completion:^(BOOL success, NSError * _Nullable error) {
          
          if (error){
              [weakSelf.logger logDev:@"Error encountered trying to process Tag Bridge command: %@", error];
          }
          
      }];
    
    return NO;
}

- (void) tagDispatchServiceWebViewReady:(UIWebView *)webView {
    
    if ([self.delegate respondsToSelector:@selector(tealium:webViewIsReady:)]) {
        
        // TODO: trigger sending dispatches
        [self.dispatchManager runQueuedDispatches];
        
        [self.delegate tealium:self webViewIsReady:webView];
    }
}

- (void) tagDispatchServiceWebView:(UIWebView*)webView encounteredError:(NSError *)error {
    
    [self.logger logQA:@"Tag Management Webview error: %@", error];
    
}

- (void) tagDispatchServiceWebView:(UIWebView*)webView processedCommandResponse:(TEALRemoteCommandResponse *)response{
    
    [self.logger logDev:@"Processed remote command: %@", response];
    
}

@end
