//
//  TEALMobileCompanionContent.h
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TEALMobileCompanionContentRow;
@class TEALMobileCompanionContentSection;

typedef NS_ENUM(NSUInteger, TEALMobileCompanionContentType){
    TEALMobileCompanionContentTypeNormal = 1,
    TEALMobileCompanionContentTypeTool
};

@interface TEALMobileCompanionContent : NSObject

/**
 *  Converts an array to TEALMobileCompanionContent
 *
 *  @param array Any NSArray of only NSDictionary objects
 *
 *  @return An instance of TEALMobileCompanionContent
 */
+ (TEALMobileCompanionContent *) contentFromArray:(NSArray *)array;

- (void) setType:(TEALMobileCompanionContentType)type;

- (void) addSectionData:(TEALMobileCompanionContentSection *)section;

- (NSArray *) headerTitles;

- (NSArray *) rowDataForSectionIndex:(NSInteger)index;

- (TEALMobileCompanionContentType) type;

@end
