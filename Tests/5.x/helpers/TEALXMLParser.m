//
//  TEALXMLParser.m
//  TealiumTests
//
//  Created by Jason Koo on 10/19/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALXMLParser.h"

@implementation TEALXMLParser

{
    LifecycleCallback callback;
    NSString *timeZone;
    NSMutableString *foundChars;
    NSMutableDictionary *event;
    NSDate *currentEventDate;
}


- (id) initWithCompletion:(LifecycleCallback) lifecycleCallback {
    
    self = [super init];
    
    if(!self || !lifecycleCallback) {
        return nil;
    }
    
    callback = lifecycleCallback;
    
    return self;
}


- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if([@"events" isEqualToString:elementName]) {
        timeZone = attributeDict[@"timezone"];
    } else if([@"event" isEqualToString:elementName]) {
        event = [NSMutableDictionary new];
        NSString *appVersion = attributeDict[@"app_version"];
        NSString *timestampUnix = attributeDict[@"timestamp_unix"];
        
        double timestamp = [timestampUnix doubleValue];
        currentEventDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        
    } else if(event) {
        event[elementName] = attributeDict[@"value"];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([@"event" isEqualToString:elementName]) {
        callback(currentEventDate, event, NO);
        event = nil;
    } else if ([@"events" isEqualToString:elementName]){
        callback(nil, nil, YES);
    }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    
}

@end
