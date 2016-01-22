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
@property (nonatomic, strong) NSDictionary *commands;
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

- (void) addReservedCommands:(TEALBooleanBlock)successBlock {
    
    __block typeof(self) __weak weakSelf = self;
    
#warning RESERVED COMMANDS NOT WORKING
    
    BOOL loadedHTTPCommand =
    [self addRemoteCommandId:TEALKeyTagRemoteReservedCommandHTTP
                 description:@"Processes tag created HTTP calls"
                 targetQueue:self.operationManager.underlyingQueue
                       block:^(TEALRemoteCommandResponse*response) {
                           
                           if (!response.error)[weakSelf executeHTTPCommandWithResponse:response completionBlock:^(TEALRemoteCommandResponse *responseB) {
                               [responseB send];
                           }];
                           
                       }];

    // For 5.1
//    __block TEALOperationManager *blockOperationManager = self.operationManager;
//    BOOL loadedMobileCompanionCommand =
//    [self addRemoteCommandId:TEALKeyTagRemoteReservedCommandMobileCompanion
//                 description:@"Remote unlock Mobile Companion"
//                 targetQueue:self.operationManager.underlyingQueue
//                       block:^(TEALRemoteCommandResponse*response) {
//                           
//                           [[NSNotificationCenter defaultCenter] postNotificationName:@"com.tealium.mobilecompanion.reveal" object:blockOperationManager];
//                       }];
    
    if (successBlock) successBlock(loadedHTTPCommand);
    
    
}

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

- (void) processRequest:(NSURLRequest*)request completionHandler:(TEALRemoteCommandResponseBlock)responseBlock {
    
    if (!self.ivarIsEnabled) {
        if (responseBlock) {
            responseBlock(nil);
        }
        return;
    }
    
    NSString *requestString = request.URL.absoluteString;
    
    // Called by CommHandler to process a Tag Bridge
    TEALRemoteCommandResponse *response = [[TEALRemoteCommandResponse alloc] initWithURLString:requestString completionHandler:responseBlock];
    
    [response setDelegate:self];
    
    if (response){
        [self triggerCommandWithResponse:response responseBlock:responseBlock];
    }
    else if (responseBlock) {
        responseBlock(nil);
    }
}

- (BOOL) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock {
    
    //
    // name - (command id) required
    // description - optional
    // queue - required
    // responseBlock - required
    
    if (!name || name == nil){
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingCommandId response:nil identifier:nil responseBlock:responseBlock];
        return NO;
    }
    if (!responseBlock || responseBlock == nil){
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingCommandBlock response:nil identifier:name responseBlock:nil];
        return NO;
    }
    
    TEALRemoteCommand *command = self.commands[name];
    
    if (!command) {
        command = [[TEALRemoteCommand alloc] init];
    }
    
    command.commandID = name;
    command.commandDescription = description;
    command.responseBlock = responseBlock;
    command.queue = queue;
    
    [self addNewCommands:@{name:command}];
    
    return YES;
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


#pragma mark - TAG REMOTE COMMAND RESPONSE DELEGATE

- (void) tealiumRemoteCommandResponseRequestsSend:(TEALRemoteCommandResponse *)response {
    
    NSString *callBackCommand = [NSString stringWithFormat:@"try {\
                                 utag.mobile.remote_api.response[\"%@\"][\"%@\"](\"%li\", '%@');\
                                 }catch(err) {\
                                 console.error(err);\
                                 }\
                                 ", response.commandId, response.responseId, (long)response.status, response.body];
    
    if (self.delegate) {
        [self.delegate tagRemoteCommandManagerRequestsCommandToWebView:callBackCommand];
    }
    
}

#pragma mark - TRIGGER REMOTE COMMANDS

- (void) triggerCommandWithResponse:(TEALRemoteCommandResponse*)response responseBlock:(TEALRemoteCommandResponseBlock)responseBlock {
    
    __block TEALRemoteCommand *command = [self commands][response.commandId];
    
    if (!command){
        
        __block typeof(self) __weak weakSelf = self;
        
        // will attempt one re-try
        if (response.status != TEALErrorCodeFailure){
            

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [weakSelf triggerCommandWithResponse:response
                                       responseBlock:responseBlock];
                
            });
            
        }
        
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingCommand
                                    response:response
                                  identifier:nil
                               responseBlock:responseBlock];
        
        // send no command response
        
        response.status = TEALErrorCodeFailure;
        response.body   = @"Command Not Found.";
        
        [weakSelf tealiumRemoteCommandResponseRequestsSend:response];

        return;
    }
    
    dispatch_queue_t queue = command.queue;
    
    if (!queue){
        
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingCommand
                                    response:response
                                  identifier:nil
                               responseBlock:responseBlock];
        
        response.status = TEALErrorCodeException;
        response.body   = @"Command Queue No Longer available.";
        
        return;
    }

    // Execute the command block to the target queue
    
    response.status = TEALErrorCodeSuccess;

    // Trigger the dispatch
    dispatch_async(queue, ^{
        
        TEALRemoteCommandResponseBlock blockActual = command.responseBlock;
        if (blockActual) blockActual(response);
        if (responseBlock)responseBlock(response);
        
    });
    
    [self tealiumRemoteCommandResponseRequestsSend:response];
    
}

#pragma mark - RESERVED COMMANDS

- (void) executeHTTPCommandWithResponse:(TEALRemoteCommandResponse*)oResponse completionBlock:(TEALRemoteCommandResponseBlock)oResponseBlock{
    
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

- (NSString*) urlString:(NSString*)urlString
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

- (NSString*) urlString:(NSString*)urlString withParametersFrom:(NSDictionary*)parameters{
    
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

- (NSMutableURLRequest*) request:(NSMutableURLRequest*)request withHeadersFrom:(NSDictionary*)headers{
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]){
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
    return request;
}

- (NSMutableURLRequest*) request:(NSMutableURLRequest*)request withBody:(id)body{
    
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
