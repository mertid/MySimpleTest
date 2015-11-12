//
//  TEALRemoteCommandResponse.m
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALRemoteCommandResponse.h"
#import "TEALRemoteCommandResponse+PrivateHeader.h"
#import "TEALRemoteCommandConstants.h"
#import "TEALRemoteCommandErrors.h"
#import "TEALRemoteCommandConstants+PrivateHeader.h"

@implementation TEALRemoteCommandResponse

- (instancetype) initWithURLString:(NSString*)urlString completionHandler:(TEALRemoteCommandResponseBlock)responseBlock {
    
    self = [super init];
    if (!self) return nil;
    
    NSString *cleanedString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!cleanedString){
        [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMalformedURL
                                       response:nil
                                     identifier:urlString
                                  responseBlock:responseBlock];
        
        return nil;
    }
    
    if ([cleanedString rangeOfString:@"tealium://"].location != NSNotFound){
        
        // Extract call data from url string
        NSString *extractedUrlString = [cleanedString stringByReplacingOccurrencesOfString:@"tealium://" withString:@""];
        if (!extractedUrlString){            
            [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMalformedURL
                                           response:nil
                                         identifier:urlString
                                      responseBlock:responseBlock];
            return nil;
        }
        
        // Extract command id - will be next 2 characters or custom charaters
        NSRange commandIdRange = [extractedUrlString rangeOfString:@"?"];
        NSUInteger commandIdindex = commandIdRange.location;
        NSString *commandId = [extractedUrlString substringToIndex:commandIdindex];
        extractedUrlString = [extractedUrlString substringFromIndex:commandIdindex];
        if (!extractedUrlString || commandIdindex > extractedUrlString.length){
            
            [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingCommandId
                                           response:nil
                                         identifier:extractedUrlString
                                      responseBlock:responseBlock];
            return nil;
        }
        self.commandId = commandId;
        
        // Extract Request Data
        NSString *dataString = [extractedUrlString substringFromIndex:commandIdRange.length];
        NSString *argString = [dataString stringByReplacingOccurrencesOfString:@"request=" withString:@""];
        
        id jsonObj;
        if (argString && argString.length > 0){
            
            NSData *jsonData = [argString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        }
        NSDictionary *requestDict = jsonObj;
        if (!requestDict) {
            
            [TEALRemoteCommandErrors returnError:TEALRemoteResponseErrorMissingRequest
                                           response:nil
                                         identifier:cleanedString
                                      responseBlock:responseBlock];
            
            return nil;
        }
        NSDictionary *payload = requestDict[TEALKeyTagRemoteCommandPayload];
        self.requestPayload = payload;
        NSDictionary *config = requestDict[TEALKeyTagRemoteCommandConfig];
        self.responseId = config[TEALKeyTagRemoteCommandResponseId];
        
    }
    return self;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"<%@: %p, Command Id: %@ Response Id: %@ Status: %li Body: %@ Error:%@>",
            NSStringFromClass([self class]), self, self.commandId, self.responseId, (long)self.status, self.body, self.error];
    
}

- (void) send{
    if (self.delegate){
        [self.delegate tealiumRemoteCommandResponseRequestsSend:self];
    }
}


@end
