//
//  TEALRemoteCommandErrors.m
//  Tealium
//
//  Created by Jason Koo on 8/26/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALRemoteCommandErrors.h"

@implementation TEALRemoteCommandErrors

+ (void) returnError:(TEALRemoteResponseErrors)errorType response:(TEALRemoteCommandResponse*)response identifier:(NSString*)identifier responseBlock:(TEALRemoteCommandResponseBlock)responseBlock {

    NSDictionary *userInfo = nil;
    NSError *error = nil;
    
    switch (errorType) {
        case TEALRemoteResponseErrorMalformedURL:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Remote api call unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Malformed or missing remote api info from %@", identifier],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure all call was properly constructed.", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Malformed
                                    userInfo:userInfo];
            break;
        case TEALRemoteResponseErrorMissingCommand:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Remote command unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Matching command id %@ not found in library.", response.commandId],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"addRemoteCommandId:description:targetQueue:block: method was not invoked for this command id prior to remote trigger.", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Failure
                                    userInfo:userInfo];
            break;
        case TEALRemoteResponseErrorMissingCommandId:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"addRemoteCommandId:description:targetQueue:block: unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Command id argument missing from addRemoteCommandId:description:targetQueue:block: method call."],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Be sure to assign a command id when invoking addRemoteCommandId:description:targetQueue:block:", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Failure
                                    userInfo:userInfo];
            break;
        case TEALRemoteResponseErrorMissingCommandBlock:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"addRemoteCommandId:description:targetQueue:block: unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Response block argument missing from addRemoteCommandId:description:targetQueue:block: method call for command id %@", identifier],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Be sure to assign a block when invoking addRemoteCommandId:description:targetQueue:block:", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Failure
                                    userInfo:userInfo];
            break;
        case TEALRemoteResponseErrorHttp_NoMethodType:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"HTTP Remote api call unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Missing target method type for call."],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure all data in remote api call is properly filled.", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Exception
                                    userInfo:userInfo];
            break;
        case TEALRemoteResponseErrorHttp_NoTargetUrl:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"HTTP Remote api call unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Missing target url string from args."],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure all data in remote api call is properly filled.", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Exception
                                    userInfo:userInfo];
            break;
        case TEALRemoteResponseErrorMissingRequest:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Remote api call unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Missing or malformed request data from %@", identifier],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check Tag Bridge call was properly constructed.", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Exception
                                    userInfo:userInfo];
            break;
        default:
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown remote api error.", nil),
                         NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Unknown error has occurred while handling a remote api call."],
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact your Tealium representative to debug.", nil)
                         };
            error = [NSError errorWithDomain:@"Tealium"
                                        code:TealiumRC_Failure
                                    userInfo:userInfo];
            break;
    }

    if (!response && responseBlock){
        response = [[TEALRemoteCommandResponse alloc] init];
    }
    response.error = error;
    if (responseBlock) responseBlock(response);
}

@end
