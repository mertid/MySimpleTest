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
    __block __weak TEALOperationManager *weakOperationManager = self.operationManager;
    
    [weakOperationManager addOperationWithBlock:^{
        
        BOOL loadedHTTPCommand =
        [weakSelf addRemoteCommandId:TEALKeyTagRemoteReservedCommandHTTP
                         description:@"Processes tag created HTTP calls"
                         targetQueue:weakOperationManager.underlyingQueue
                               block:^(TEALRemoteCommandResponse*response) {
                                   
                                   if (!response.error)[weakSelf executeHTTPCommandWithResponse:response completionBlock:^(TEALRemoteCommandResponse *responseB) {
                                       [responseB send];
                                   }];
                                   
                               }];
        
        BOOL loadedMobileCompanionCommand =
        [weakSelf addRemoteCommandId:TEALKeyTagRemoteReservedCommandMobileCompanion
                         description:@"Remote unlock Mobile Companion"
                         targetQueue:weakOperationManager.underlyingQueue
                               block:^(TEALRemoteCommandResponse*response) {
                                   
#warning THIS only works if the call comes in at least twice
                                   
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"com.tealium.mobilecompanion.reveal" object:weakOperationManager];
                               }];
        
        if (successBlock) successBlock(loadedHTTPCommand && loadedMobileCompanionCommand);
        
    }];
    
    
    
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
    // queue optional - will fall back to main thread
    // command optional - could be filled in later
    
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
    
    [self.operationManager addOperationWithBlock:^{
        self.commands = newCommands;
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

- (BOOL) triggerCommandWithResponse:(TEALRemoteCommandResponse*)response responseBlock:(TEALRemoteCommandResponseBlock)responseBlock {
    
    __block TEALRemoteCommand *command = [self commands][response.commandId];

    dispatch_queue_t queue = command.queue;
    
    BOOL success = NO;
    
    // Execute the command block to the target queue
    if (queue){
        
        // Trigger the dispatch
        dispatch_async(queue, ^{
            TEALRemoteCommandResponseBlock blockActual = command.responseBlock;
            if (blockActual) blockActual(response);
            if (responseBlock)responseBlock(response);
        });
        
        success = YES;
    } else {
        
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingCommand response:response identifier:nil responseBlock:responseBlock];
        
        // send no command response
        
        response.status = TealiumRC_Failure;
        response.body   = @"Command Not Found";
        
        success = NO;
    }
    
    [self tealiumRemoteCommandResponseRequestsSend:response];
    
    return success;
}

#pragma mark - RESERVED COMMANDSZ

- (void) executeHTTPCommandWithResponse:(TEALRemoteCommandResponse*)oResponse completionBlock:(TEALRemoteCommandResponseBlock)oResponseBlock{
    
    /* TEMPLATE OF RWEMOTE API COMMAND DICT
     
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
    if (authenticate) { urlString = [self urlString:urlString withAuthentificationFrom:authenticate];}
    
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
                                   [tResponse setStatus:TealiumRC_Exception];
                               }
                               if (responseBlock) responseBlock(tResponse);
                           }];
}

#pragma mark - HELPERS

- (NSString*) urlString:(NSString*)urlString withAuthentificationFrom:(NSDictionary*)authentification{
    
    // Failure will return original urlString passed in.
    
    NSString *username = authentification[TEALKeyTagRemoteCommandUsername];
    NSString *password = authentification[TEALKeyTagRemoteCommandPassword];
    
    if (!username || [username isEqualToString:@""]){
        //        TEALIUMLOG(@"Remote API call %@ - username key found but missing value.", urlString);
    }
    else if (!password || [password isEqualToString:@""]){
        //        TEALIUMLOG(@"Remote API Call %@ - password key found but missing value.", urlString);
    }
    else {
        NSString *httpPrefix = [urlString substringToIndex:6];
        NSString *httpsPrefix = [urlString substringToIndex:7];
        NSString *urlStringstripped;
        if ([httpPrefix isEqualToString:@"http://"]) urlStringstripped = [urlString substringFromIndex:6];
        if ([httpsPrefix isEqualToString:@"https://"]) urlStringstripped = [urlString substringFromIndex:7];
        if (!urlStringstripped || urlStringstripped.length == 0) {
            
#warning SOME ERROR HANDLING?
//            TEALIUMELOG(@"Could not properly parse %@ url string of http:// prefix.", urlString);
            
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
