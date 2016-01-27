//
//  TEALRemoteCommands.m
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALRemoteCommandManager.h"
#import "TEALOperationManager.h"
#import "TEALRemoteCommand.h"
#import "TEALRemoteCommandErrors.h"
#import "TEALRemoteCommandConstants.h"
#import "TEALRemoteCommandConstants+PrivateHeader.h"
#import "TEALError.h"

@interface TEALRemoteCommandManager()

@property (nonatomic) BOOL ivarIsEnabled;
@property (nonatomic, weak) TEALOperationManager *operationManager;

@end

@implementation TEALRemoteCommandManager

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithOperationManager:(TEALOperationManager*)manager {
    
    self = [super init];
    if (self){
        
        _operationManager = manager;
        
    }
    return self;
    
}

//- (void) addReservedCommands:(TEALBooleanCompletionBlock)completion {
//    
//    __block typeof(self) __weak weakSelf = self;
//    
//#warning RESERVED COMMANDS NOT WORKING
//        
//    [self addRemoteCommandID:TEALKeyTagRemoteReservedCommandHTTP
//                 description:@"Process tag created HTTP calls."
//                 targetQueue:self.operationManager.underlyingQueue
//               responseBlock:^(TEALRemoteCommandResponse *response) {
//                   
//                   if (response.error){
//                       if (weakSelf.delegate){
//                           [weakSelf.delegate remoteCommandManagerReportedError:response.error];
//                       }
//                       return;
//                   }
//                   
//                   [weakSelf executeHTTPCommandWithResponse:response completionBlock:^(TEALRemoteCommandResponse *responseB) {
//                       [responseB send];
//                   }];
//                   
//               } completion:completion];
//    
//}

//- (void) addReservedCommands:(TEALBooleanBlock)successBlock {
//    
//    __block typeof(self) __weak weakSelf = self;
//    
//#warning RESERVED COMMANDS NOT WORKING
//    
//    __block BOOL loadedHTTPCommand = NO;
//    
//    [self addRemoteCommandID:TEALKeyTagRemoteReservedCommandHTTP
//                 description:@"Process tag created HTTP calls."
//                 targetQueue:self.operationManager.underlyingQueue
//               responseBlock:^(TEALRemoteCommandResponse *response) {
//                   
//                   if (response.error){
//                       if (weakSelf.delegate){
//                           [weakSelf.delegate remoteCommandManagerReportedError:response.error];
//                       }
//                       return;
//                   }
//                   
//                   [weakSelf executeHTTPCommandWithResponse:response completionBlock:^(TEALRemoteCommandResponse *responseB) {
//                       [responseB send];
//                   }];
//                   
//               } completion:^(BOOL success, NSError * _Nullable error) {
//                  
//                   loadedHTTPCommand = success;
//                   
//                   if (loadedHTTPCommand  &&
//                       successBlock){
//                       successBlock(YES);
//                   }
//                   
//                   if (weakSelf.delegate &&
//                       error){
//                       [weakSelf.delegate remoteCommandManagerReportedError:error];
//                   }
//               }];
//    
//}

- (void) enable {
    
    if (!self.ivarIsEnabled) {
        self.ivarIsEnabled = YES;
    }
    
}

- (void) disable {
    if (self.ivarIsEnabled) {
        self.ivarIsEnabled = NO;
    }
}

- (BOOL) isEnabled {
    return self.ivarIsEnabled;
}

- (void) processCommandString:(NSString *)commandString
                responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                   completion:(TEALBooleanCompletionBlock)completion {
    
    NSError *error;
    
    NSString *commandID = [TEALRemoteCommandManager commandIDFromCommandString:commandString];
    if (!commandID){
        
        NSString *reason = [NSString stringWithFormat:@"Command ID Missing from command string: %@", commandString];
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Could not process command.", @"")
                                  reason:reason
                              suggestion:NSLocalizedString(@"Check Tag Bridge Tag in TIQ", @"")];
        
        if (completion){
            completion(NO, error);
        }
        return;
    }
    
    NSDictionary *requestData = [TEALRemoteCommandManager requestDataFromCommandString:commandString error:error];
    if (!requestData ||
        error){
        
        if (completion){
            completion(NO, error);
        }
        return;
    }
    
    NSDictionary *payload = [TEALRemoteCommandManager payloadFromRequestData:requestData error:error];
    if (!payload ||
        error){
        
        if (completion){
            completion(NO, error);
        }
        return;
    }
    
    // Optional
    NSString *responseID = [TEALRemoteCommandManager responseIDFromRequestData:requestData error:error];
    
    TEALRemoteCommandResponse *response = [[TEALRemoteCommandResponse alloc] init];
    if (!response){
        
        NSString *description = [NSString stringWithFormat:@"Could not process command from: %@", commandString];
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:description
                                  reason:NSLocalizedString(@"Could not init a response object", @"")
                              suggestion:NSLocalizedString(@"Consult Tealium Engineering - processCommandString:responseBlock:completion:", @"")];
        
        if (completion){
            completion(NO, error);
        }
        return;
    }
    
    // Final response setup
    response.status = 0;
    response.commandId = commandID;
    response.requestPayload = payload;
    response.responseId = responseID;
    response.commandId = commandID;
    [response setDelegate:self];
    
    [self triggerCommandWithResponse:response
                       responseBlock:responseBlock
                          completion:completion];
}

- (void) addRemoteCommandID:(NSString*)commandID
                description:(NSString*)description
                targetQueue:(dispatch_queue_t)queue
              responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                 completion:(TEALBooleanCompletionBlock)completion {
    
    NSError *error = nil;
    
    if (!self.isEnabled){
        error = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Could not add remote command.", @"")
                                  reason:NSLocalizedString(@"Remote Command Manager not enabled.", @"")
                              suggestion:NSLocalizedString(@"Make sure Tag Management is enabled in Publish settings & Remote Commands are enabled in configuration object.", @"")];
        if (completion){
            completion(NO, error);
        }
        return;
    }
    
    if (!commandID){
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Could not add remote command.", @"")
                                  reason:NSLocalizedString(@"Call missing command id argument.", @"")
                              suggestion:NSLocalizedString(@"Add id argument to addRemoteCommandID:description:targetQueue:responseBlock: call.", @"")];
        if (completion){
            completion(NO, error);
        }
    }
    
    if (!responseBlock){
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Could not add remote command.", @"")
                                  reason:NSLocalizedString(@"Call missing Response block argument.", @"")
                              suggestion:NSLocalizedString(@"Add responseBlock argument to addRemoteCommandID:description:targetQueue:responseBlock: call.", @"")];
        if (completion){
            completion(NO, error);
        }
    }
    
    TEALRemoteCommand *command = self.commands[commandID];
    
    if (!command) {
        command = [[TEALRemoteCommand alloc] init];
    }
    
    // command id - required
    // description - optional
    // queue - required
    // responseBlock - required
    
    command.commandID = commandID;
    command.commandDescription = description;
    command.responseBlock = responseBlock;
    command.queue = queue;
    
    [self addNewCommands:@{commandID:command}];
    
    if (completion){
        completion(YES, nil);
    }
    
}

- (void) removeRemoteCommandID:(NSString *)name
                    completion:(TEALBooleanCompletionBlock)completion {
    
    NSDictionary *commands = [self.commands copy];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:commands];
    
    [mDict removeObjectForKey:name];
    
    NSDictionary *newCommands = [NSDictionary dictionaryWithDictionary:mDict];
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        
        weakSelf.commands = newCommands;
        if (completion) completion(YES, nil);
        
    }];
}

#pragma mark - PRIVATE INSTANCE

- (void) addNewCommands:(NSDictionary *)newCommand {
    
    NSDictionary *commands = [self.commands copy];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:commands];
    [mDict addEntriesFromDictionary:newCommand];
    NSDictionary *newCommands = [NSDictionary dictionaryWithDictionary:mDict];
    
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        weakSelf.commands = newCommands;
    }];
}

#pragma mark - PUBLIC CLASS

+ (NSString *) commandStringFromURLString:(NSString *)urlString
                                    error:(NSError * __autoreleasing)error{
    
    // Stripping the tealium:// prefix from request url
    
    NSString * cleanedString = [urlString stringByRemovingPercentEncoding];
    
    if ([cleanedString rangeOfString:@"tealium://"].location == NSNotFound){
        
        NSString *description = [NSString stringWithFormat:@"No Tag Bridge command info from url string: %@", urlString];
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:description
                                  reason:NSLocalizedString(@"tealium:// prefix missing", @"")
                              suggestion:NSLocalizedString(@"No corrections - this is not a Tag Bridge command.", @"")];
        return nil;
        
    }
    
    // Focus on data after id prefix
    NSString *extractedUrlString = [cleanedString stringByReplacingOccurrencesOfString:@"tealium://" withString:@""];
    
    if (!extractedUrlString){
        
        NSString *description = [NSString stringWithFormat:@"No Tag Bridge command info from url string: %@", urlString];
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:description
                                  reason:NSLocalizedString(@"No data after tealium:// prefix.", @"")
                              suggestion:NSLocalizedString(@"Malformed Tag Bridge Command from UTAG.", @"")];
        return nil;
    }
    
    return extractedUrlString;
    
}

+ (NSString *) commandIDFromCommandString:(NSString *)commandString {
    
    NSRange commandIdRange = [commandString rangeOfString:@"?"];
    
    NSUInteger commandIdindex = commandIdRange.location;
    
    NSString *commandId = [commandString substringToIndex:commandIdindex];
    
    return commandId;
    
}

+ (NSDictionary *) requestDataFromCommandString:(NSString *)commandString
                                      error:(NSError * __autoreleasing)error{

    
    // Extract Request Data after the command id + ?
    
    // skip over command id + ? + request=
    NSRange startRange = [commandString rangeOfString:@"="];

    NSUInteger startIndex = startRange.location + 1;
    
    NSString *argString = [commandString substringFromIndex:startIndex];
    
    id jsonObj;
    
    if (argString && argString.length > 0){
        
        NSData *jsonData = [argString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        
        jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        
        if (jsonError){
            error = jsonError;
            return nil;
        }
    }
    
    NSDictionary *requestDict = jsonObj;
    
    if (!requestDict) {
        
        error = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Could not extract payload from Tag Bridge command string.", @"")
                                  reason:NSLocalizedString(@"Could not parse data to JSON.", @"")
                              suggestion:NSLocalizedString(@"Check command string from template.", @"")];
        
        return nil;
    }
    
    return requestDict;
    
}

+ (NSString *) responseIDFromRequestData:(NSDictionary *)requestData
                                   error:(NSError * __autoreleasing)error {
    
    NSDictionary *config = requestData[TEALKeyTagRemoteCommandConfig];

    if (!config){
        error = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"Could not retrieve response id from request data.", @"")
                                  reason:NSLocalizedString(@"Config data not found.", @"")
                              suggestion:NSLocalizedString(@"Check Tag Bridge Tag Template.", @"")];
        return nil;
    }
    
    NSString *responseID = config[TEALKeyTagRemoteCommandResponseId];
    
    if (!responseID){
        error = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"Could not retrieve response id from request data.", @"")
                                  reason:NSLocalizedString(@"Config data did not contain response id.", @"")
                              suggestion:NSLocalizedString(@"Check Tag Bridge Tag Template.", @"")];
        return nil;
    }
    
    return responseID;
    
}

+ (NSDictionary *) payloadFromRequestData:(NSDictionary*)requestData
                                    error:(NSError * __autoreleasing)error{
    
    NSDictionary *payload = requestData[TEALKeyTagRemoteCommandPayload];
    
    if (!payload){
        error = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"No Payload in request data.", @"")
                                  reason:NSLocalizedString(@"No Payload found.", @"")
                              suggestion:NSLocalizedString(@"Check mapping to Tag Bridge Tag.", @"")];
        return nil;
    }

    return payload;
}

#pragma mark - TAG REMOTE COMMAND RESPONSE DELEGATE

- (void) tealiumRemoteCommandResponseRequestsSend:(TEALRemoteCommandResponse *)response {
    
//    NSString *callBackCommand = [NSString stringWithFormat:@"try {\
//                                 utag.mobile.remote_api.response['%@']('','');\
//                                 }catch(err) {\
//                                 console.error(err);\
//                                 }\
//                                 ", response.commandId];
    
    NSString *callBackCommand = [NSString stringWithFormat:@"try {\
                                 utag.mobile.remote_api.response[\"%@\"][\"%@\"](\"%li\", '%@');\
                                 }catch(err) {\
                                 console.error(err);\
                                 }\
                                 ", response.commandId, response.responseId, (long)response.status, response.body];
    
    if (self.delegate) {
        [self.delegate remoteCommandManagerRequestsCommandToWebView:callBackCommand];
    }
    
}

#pragma mark - TRIGGER REMOTE COMMANDS

- (void) triggerCommandWithResponse:(TEALRemoteCommandResponse*)response
                      responseBlock:(TEALRemoteCommandResponseBlock)responseBlock
                         completion:(TEALBooleanCompletionBlock)completion{

    NSError *error = nil;
    
    __block TEALRemoteCommand *command = [self commands][response.commandId];

    if (!command){
        
        NSString *description = [NSString stringWithFormat:@"Could not trigger command id: %@", response.commandId];
        
        error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                             description:description
                                  reason:NSLocalizedString(@"Command block not yet added via the addRemoteCommandID:description:targetQueue:responseBlock: method.", @"")
                              suggestion:NSLocalizedString(@"Adjust timing of command in TIQ or add remote command block earlier.", @"")];
        
        if (completion){
            completion(NO, error);
        }
        [self tealiumRemoteCommandResponseRequestsSend:response];
        return;
    }
    
    dispatch_queue_t queue = command.queue;

    // If no queue was provided in addRemoteCommandID... method, default to main thread
    if (!queue){
        
        queue = dispatch_get_main_queue();
        
    }
    
    response.status = TEALErrorCodeSuccess;
    
    // Trigger the dispatch
    dispatch_async(queue, ^{
        
        TEALRemoteCommandResponseBlock blockActual = command.responseBlock;
        if (blockActual) blockActual(response);
        if (responseBlock)responseBlock(response);
        if (completion)completion(YES, nil);
        
    });
    
    [self tealiumRemoteCommandResponseRequestsSend:response];
    
}

#pragma mark - RESERVED COMMANDS

+ (void) executeHTTPCommandWithResponse:(TEALRemoteCommandResponse*)oResponse completionBlock:(TEALRemoteCommandResponseBlock)oResponseBlock{
    
    // TODO: Optimize this block to use &error as in the authenticate check below
    
    /* TEMPLATE OF REMOTE API COMMAND DICT
     
     commandId:{
     authenticate:{
     username:'',
     password:''
     },
     url:'https://www.blah.com',
     headers:{
     'header':'value'
     },
     parameters:{
     'someKey':'someValue'
     },
     body:{
     'someKey':'someValue'
     } // or entirely a string
     },
     method:'post/get/put',
     response_id:'someId'
     }
     */
    
    __block TEALRemoteCommandResponse *tResponse = oResponse;
    __block TEALRemoteCommandResponseBlock responseBlock = oResponseBlock;
    
    NSDictionary *commandDict = tResponse.requestPayload;
    __block NSString *urlString = commandDict[TEALKeyTagRemoteCommandURL];
    NSDictionary *authenticate = commandDict[TEALKeyTagRemoteCommandAuthenticate];
    NSDictionary *headers = commandDict[TEALKeyTagRemoteCommandHeaders];
    NSDictionary *parameters = commandDict[TEALKeyTagRemoteCommandParameters];
    NSString *body = commandDict[TEALKeyTagRemoteCommandBody];
    NSString *method = commandDict[TEALKeyTagRemoteCommandMethod];
    NSError *error = nil;
    
    // Check for minimum needed data
    if (!urlString){
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorHttp_NoTargetUrl response:tResponse identifier:nil responseBlock:responseBlock];
        return;
    }
    if (!method){
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorHttp_NoMethodType response:tResponse identifier:nil responseBlock:responseBlock];
        return;
    }
    
    // Set Authentification
    if (authenticate) {
        urlString = [self urlString:urlString withAuthentificationFrom:authenticate error:&error];
        if (error){
            if (responseBlock){
                tResponse.error = error;
                responseBlock(tResponse);
            }
            return;
        }
    }
    
    // Set Parameters (post url data)
    if (parameters){ urlString = [self urlString:urlString withParametersFrom:parameters];}
    
    // Set HTTP Config
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    
    // Set Headers
    if (headers) request = [self request:request withHeadersFrom:headers];
    
    // Set body if not GET
    if(![method isEqualToString:@"get"]) {
        // Set Data Body
        if (body) request = [self request:request withBody:body];
    }
    
    // Make call
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (response){
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                   NSInteger responseCode = httpResponse.statusCode;
                                   NSString *bodyAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   [tResponse setStatus:responseCode];
                                   [tResponse setBody:bodyAsString];
                               }
                               if (connectionError){
                                   [tResponse setError:connectionError];
                                   [tResponse setStatus:TEALErrorCodeException];
                               }
                               if (responseBlock) responseBlock(tResponse);
                           }];
}

#pragma mark - HELPERS

+ (NSString*) urlString:(NSString*)urlString
withAuthentificationFrom:(NSDictionary*)authentification
                  error:(NSError * __autoreleasing *)error{
    
    // Failure will return original urlString passed in.
    
    NSString *username = authentification[TEALKeyTagRemoteCommandUsername];
    NSString *password = authentification[TEALKeyTagRemoteCommandPassword];
    
    if (!username || [username isEqualToString:@""]){
        //        TEALIUMLOG(@"Remote API call %@ - username key found but missing value.", urlString);
    } else if (!password || [password isEqualToString:@""]){
        //        TEALIUMLOG(@"Remote API Call %@ - password key found but missing value.", urlString);
    } else {
        NSString *httpPrefix = [urlString substringToIndex:6];
        NSString *httpsPrefix = [urlString substringToIndex:7];
        NSString *urlStringstripped;
        if ([httpPrefix isEqualToString:@"http://"]) urlStringstripped = [urlString substringFromIndex:6];
        if ([httpsPrefix isEqualToString:@"https://"]) urlStringstripped = [urlString substringFromIndex:7];
        if (!urlStringstripped || urlStringstripped.length == 0) {
            
            if (error){
                NSString *reason = [NSString stringWithFormat:@"Could not parse urlString: %@", urlString];
                *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                     description:NSLocalizedString(@"HTTP Authentication failed.", @"")
                                          reason:reason
                                      suggestion:NSLocalizedString(@"Consult Tealium Engineering.", @"")];
            }

            return nil;
        }
        NSString *newUrlString = [NSString stringWithFormat:@"https://%@:%@@%@", username, password, urlStringstripped];
        if (newUrlString) return newUrlString;
    }
    
    return urlString;
}

+ (NSString*) urlString:(NSString*)urlString withParametersFrom:(NSDictionary*)parameters{
    
    // Failure will return original urlString passed in.
    
    NSString *newUrlString = nil;
    
    if ([parameters count] == 0) newUrlString = urlString;
    else {
        NSMutableString *suffixString = [NSMutableString stringWithFormat:@"?"];
        
        NSMutableArray *sortKeys = [NSMutableArray arrayWithArray:[parameters allKeys]];
        [sortKeys sortUsingSelector:@selector(compare:)];
        for (unsigned int i = 0; i < [sortKeys count]; i++){
            id key = sortKeys[i];
            id obj = parameters[key];
            if ([obj isKindOfClass:[NSString class]]){
                if (![suffixString isEqualToString:@"?"])[suffixString appendFormat:@"&"];
                [suffixString appendFormat:@"%@=%@", key, obj];
            }
        }
        if (suffixString) newUrlString = [urlString stringByAppendingString:suffixString];
    }
    return newUrlString;
}

+ (NSMutableURLRequest*) request:(NSMutableURLRequest*)request withHeadersFrom:(NSDictionary*)headers{
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]){
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
    return request;
}

+ (NSMutableURLRequest*) request:(NSMutableURLRequest*)request withBody:(id)body{
    
    if (body){
        NSData *jsonData = nil;
        if ([body isKindOfClass:[NSDictionary class]]){
            NSError *error = nil;
            jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:0
                                                         error:&error];
        }
        else if ([body isKindOfClass:[NSString class]]){
            jsonData = [(NSString *) body dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if (jsonData){
            [request setHTTPBody:jsonData];
            // Add content-length added here for convenience
            NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
            [request setValue:length forHTTPHeaderField:@"Content-Length"];
        }
    }
    
    return  request;
}

@end
