//
//  TEALRemoteCommand.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALRemoteCommand.h"
#import "NSString+Tealium.h"

@implementation TEALRemoteCommand

- (NSString *) description {
    
    NSString *queueName = [NSString stringWithFormat:@"%s", dispatch_queue_get_label(self.queue)];
    
    NSDictionary *descriptionData = @{
                                      @"commandID":[NSString teal_dictionarySafeString:self.commandID],
                                      @"decription":[NSString teal_dictionarySafeString:self.commandDescription],
                                      @"queue":[NSString teal_dictionarySafeString:queueName],
                                      @"hasCommandBlock":self.responseBlock?@"YES":@"NO"
                                      };
    
    return [NSString teal_descriptionForObject:self description:nil fromDictionary:descriptionData];
}

@end
