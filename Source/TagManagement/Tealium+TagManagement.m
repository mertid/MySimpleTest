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
#import "TEALRemoteCommandConstants+PrivateHeader.h"
#import "TEALRemoteCommandManager.h"
#import "TEALSettings+TagManagement.h"
#import "TEALError.h"

@interface Tealium() <TEALTagDispatchServiceDelegate, TEALRemoteCommandManagerDelegate>

@end

@implementation Tealium (TagManagement)

#pragma mark - PUBLIC INSTANCE

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
                          [weakSelf.logger logDev:@"Added remote command for id: %@", commandID];
                      }
                      if (error){
                          [weakSelf.logger logDev:@"Error adding remote command block %@: %@", commandID, error];
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
    
    if ([self.settings tagManagementEnabled]){
        
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
    
    if ([[[self currentDispatchServices] copy] teal_containsObjectOfClass:[TEALTagDispatchService class]]){
        return;
    }

    TEALTagDispatchService *tagService = [self currentTagDispatchService];
    
    if (!tagService){
        tagService = [self newTagDispatchService];
        [self addNewDispatchService:tagService];
    }

}

- (void) enableRemoteCommands {
    
//    TEALTagDispatchService *service = [self currentTagDispatchService];
//        
//    [service.remoteCommandManager enable];
//    
//    if (![service.remoteCommandManager isEnabled]){
    
//        [self.logger logDev:@"Could not enable remote commands - check that Tag Management services enabled."];
        
//        return;
//    }

    if ([[self remoteCommandManager] isEnabled]){
        return;
    }
    
    [[self remoteCommandManager] enable];
    
    [self.logger logDev:@"Remote Commands enabled."];

//    __block typeof(self) __weak weakSelf = self;
    
    [self addReservedCommands];
    
//    [[self remoteCommandManager] addReservedCommands:^(BOOL success, NSError * _Nullable error) {
//        
//        if (!success ||
//            error){
//            
//            [weakSelf.logger logDev:@"Problem adding reserved commands: logged error:%@", error];
//            return;
//            
//        }
//        
//        [weakSelf.logger logDev:@"Added Reserved Remote Commands."];
//
//    }];

    
}

- (void) disableTagManagement {

    [self removeDispatchService:[self currentTagDispatchService]];
    
}

- (void) disableRemoteCommands {
    
    [[self remoteCommandManager] disable];
    
}

- (void) addReservedCommands {
    
    __block typeof(self) __weak weakSelf = self;
    
    [self addRemoteCommandID:TEALKeyTagRemoteReservedCommandHTTP
                 description:@"Process tag created HTTP calls."
                 targetQueue:self.operationManager.underlyingQueue
               responseBlock:^(TEALRemoteCommandResponse *response) {
                   
                   if (response.error){
                       [weakSelf.logger logDev:@"Problem executing reserved remote command: %@ - response: %@", TEALKeyTagRemoteReservedCommandHTTP, response];
                       return;
                   }
                   
                   [TEALRemoteCommandManager executeHTTPCommandWithResponse:response
                                                            completionBlock:^(TEALRemoteCommandResponse *response) {
                                                                
                                                                [response send];
                                                            }];
                   
//                   [weakSelf executeHTTPCommandWithResponse:response completionBlock:^(TEALRemoteCommandResponse *responseB) {
//                       [responseB send];
//                   }];
                   
               } completion:^(BOOL success, NSError * _Nullable error) {
                   
                   if (success){
                       [weakSelf.logger logDev:@"Added reserved remote command for id: %@", TEALKeyTagRemoteReservedCommandHTTP];
                   }
                   if (error){
                       [weakSelf.logger logDev:@"Error adding remote command block %@: %@", TEALKeyTagRemoteReservedCommandHTTP, error];
                   }
               }];
    
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
            }
        }
        
        [manager addRemoteCommandID:name
                        description:description
                        targetQueue:queue
                      responseBlock:responseBlock
                         completion:^(BOOL success, NSError * _Nullable error) {
                             
                             if (completion){
                                 completion(success, error);
                             }
                         }];
        
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
                                         completion:^(BOOL success, NSError * _Nullable error) {
                                             
                                             if (completion){
                                                 completion(success, error);
                                             }
                                             
                                         }];
        
    }];
    
}

//- (UIWebView *) webView {
//    
//    TEALTagDispatchService *currentService = [self currentTagDispatchService];
//    
//    return currentService.webView;
//    
//}

- (WKWebView *) webView {
    
    TEALTagDispatchService *currentService = [self currentTagDispatchService];
    
    return currentService.wkWebView;
    
}

#pragma mark - HELPERS

- (TEALTagDispatchService *) currentTagDispatchService {
    
    __block TEALTagDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [[self currentDispatchServices] copy];
    
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

- (void) remoteCommandManagerRequestsCommandToWebView:(NSString *)command {
    
    __block typeof(self) __weak weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [weakSelf.webView evaluateJavaScript:command
                           completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                               
                               if (!error){
                                   return;
                               }
                               
                               NSString *errorDescription = [NSString stringWithFormat:@"Could not process callback command: %@ - error: %@", command, error];
                               
                               NSError *formattedError = [TEALError errorWithCode:TEALErrorCodeFailure
                                                             description:errorDescription
                                                                  reason:NSLocalizedString(@"Command did not execute.", @"")
                                                              suggestion:NSLocalizedString(@"Check command id in TIQ", @"")];
                               
                               [weakSelf.logger logDev:@"Error executing Tag Bridge Command: %@", formattedError];
                               
                           }];
        
//        NSString *init = [weakSelf.webView stringByEvaluatingJavaScriptFromString:command];
//        
//        if ([[init lowercaseString] isEqualToString:@"false"]){
//            
//            NSString *errorDescription = [NSString stringWithFormat:@"Could not process callback command: %@", command];
//            NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
//                                          description:errorDescription
//                                               reason:NSLocalizedString(@"Command did not execute.", @"")
//                                           suggestion:NSLocalizedString(@"Check command id in TIQ", @"")];
//            
//            [weakSelf.logger logDev:@"Error executing Tag Bridge Command: %@", error];
//        }
    });
}
//- (void) remoteCommandManagerRequestsCommandToWebView:(NSString *)command {
//    
//    __block typeof(self) __weak weakSelf = self;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        NSString *init = [weakSelf.webView stringByEvaluatingJavaScriptFromString:command];
//        
//        if ([[init lowercaseString] isEqualToString:@"false"]){
//            
//            NSString *errorDescription = [NSString stringWithFormat:@"Could not process callback command: %@", command];
//            NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
//                                          description:errorDescription
//                                               reason:NSLocalizedString(@"Command did not execute.", @"")
//                                           suggestion:NSLocalizedString(@"Check command id in TIQ", @"")];
//            
//            [weakSelf.logger logDev:@"Error executing Tag Bridge Command: %@", error];
//        }
//    });
//}

- (void) remoteCommandManagerReportedError:(NSError *)error {
    
    [self.logger logDev:@"Remote command error: %@", error];
    
}
#pragma mark - TEAL TAG DISPATCH SERVICE DELEGATE

- (BOOL) tagDispatchServiceShouldPermitRequest:(NSURLRequest *)request{
    
    NSString *urlString = request.URL.absoluteString;
    
    NSError *error = nil;
    
    __block NSString *commandString = [TEALRemoteCommandManager commandStringFromURLString:urlString error:error];

    if (!commandString){
        return YES;
    }
    
    if (error){
        [self.logger logDev:@"Remote command processing error: %@", error];
    }

    __block typeof(self) __weak weakSelf = self;

    [self.remoteCommandManager processCommandString:commandString
                                      responseBlock:^(TEALRemoteCommandResponse *response) {
                                          
                                          
                                          [weakSelf.logger logDev:@"Processed command: %@ - response: %@", commandString, response];
                                        
                                          
                                      } completion:^(BOOL success, NSError * _Nullable error) {
                                          
                                          if (error){
                                              [weakSelf.logger logDev:@"Error encountered trying to process Tag Bridge command: %@", error];
                                          }
                                          
                                      }];
        
    
    return NO;
}

- (void) tagDispatchServiceWKWebViewReady:(id)wkWebView {

    [self.logger logDev:@"WKWebView ready: %@", wkWebView];
    
    if ([self.delegate respondsToSelector:@selector(tealium:webViewIsReady:)]) {
        
        [self.delegate tealium:self webViewIsReady:wkWebView];
    }
    
}

- (void) tagDispatchServiceWKWebViewCallback:(NSString *)message {
    
    [self.logger logDev:@"WKWebView callback message: %@", message];

}

//- (void) tagDispatchServiceWebViewReady:(UIWebView *)webView {
//    
//    if ([self.delegate respondsToSelector:@selector(tealium:webViewIsReady:)]) {
//        
//        [self.delegate tealium:self webViewIsReady:webView];
//    }
//    
//    [self.logger logDev:@"UIWebView ready: %@", webView];
//
//}
//
- (void) tagDispatchServiceWebView:(UIWebView*)webView encounteredError:(NSError *)error {
    
    [self.logger logQA:@"Tag Management Webview error: %@", error];
    
}
//
//- (void) tagDispatchServiceWebView:(UIWebView*)webView processedCommandResponse:(TEALRemoteCommandResponse *)response{
//    
//    [self.logger logDev:@"Processed remote command: %@", response];
//    
//}

@end
