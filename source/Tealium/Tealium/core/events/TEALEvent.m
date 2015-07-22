//
//  TEALEvent.m
//  Tealium Mobile Library
//
//  Created by George Webster on 5/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALEvent.h"
#import <UIKit/UIKit.h>
#import "TEALDatasources.h"

// Event Type Strings

NSString * const TEALEventTypeLinkStringValue = @"link";
NSString * const TEALEventTypeViewStringValue = @"view";

@implementation TEALEvent


+ (NSString *) titleForEvent:(TEALEventType)eventType
                  withObject:(NSObject *)obj {

    NSString *title = nil;
    
    switch (eventType) {
        case TEALEventTypeLink:
            title = [TEALEvent titleForTouchEventWithObject:obj];
            break;

        case TEALEventTypeView:
            title = [TEALEvent titleForViewEventWithObject:obj];
            break;
    }
    
    return title;
}


+ (NSString *) titleForTouchEventWithObject:(NSObject *)obj {
    
    NSString *title = nil;
    
    if ([obj respondsToSelector:@selector(title)]) {
        
        title = [obj performSelector:@selector(title)];
        
    } else if ([obj respondsToSelector:@selector(currentTitle)]) {
        
        title = [obj performSelector:@selector(currentTitle)];
        
    } else if ([obj respondsToSelector:@selector(possibleTitles)]) {
        
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
        
    } else if ([obj respondsToSelector:@selector(selectedSegmentIndex)] &&
               [obj respondsToSelector:@selector(titleForSegmentAtIndex:)]) {
        
        UISegmentedControl *seg = (UISegmentedControl *)obj;
        int si = (int)[seg selectedSegmentIndex];
        int s = (int)[seg numberOfSegments];
        if (si >= 0 && si < s) title = [seg titleForSegmentAtIndex:si];
        
    } else if ([obj respondsToSelector:@selector(titleLabel)]) {
        
        UILabel *label =  [obj performSelector:@selector(titleLabel)];
        title = [label text];
    }
    return title;
}

+ (NSString *) titleForViewEventWithObject:(NSObject *)obj {

    NSString *title = nil;
    
    if ([obj isKindOfClass:[UIWebView class]]) {
        title = @"webview";
        
    } else if ([obj respondsToSelector:@selector(title)]) {
        
        title = [obj performSelector:@selector(title)];
        
    } else if ([obj respondsToSelector:@selector(currentTitle)]) {
        
        title = [obj performSelector:@selector(currentTitle)];
        
    } else if ([obj respondsToSelector:@selector(possibleTitles)]) {
        
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
        
    } else if ([obj respondsToSelector:@selector(restorationIdentifier)]) {
        
        title = [obj performSelector:@selector(restorationIdentifier)];

    } else if ([obj respondsToSelector:@selector(nibName)]) {
    
        title = [obj performSelector:@selector(nibName)];
    }

    return title;
}

+ (NSDictionary *) datasourcesForEvent:(TEALEventType)eventType
                            withObject:(NSObject *)obj
                           autotracked:(BOOL)autotracked {
    
    NSMutableDictionary *datasources = [NSMutableDictionary dictionary];

    if (autotracked) {
        datasources[TEALDatasourceKey_Autotracked] = TEALDatasourceValue_True;
    }
    
    // TODO: add processing center logic for supported object datasources
    
    return [NSDictionary dictionaryWithDictionary:datasources];
}


@end
