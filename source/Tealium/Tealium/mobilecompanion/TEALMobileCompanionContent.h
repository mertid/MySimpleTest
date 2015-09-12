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

@interface TEALMobileCompanionContent : NSObject

+ (TEALMobileCompanionContent *) contentFromArray:(NSArray *)array;

- (void) addSectionData:(TEALMobileCompanionContentSection *)section;

- (NSArray *) headerTitles;

- (NSArray *) rowDataForSectionIndex:(NSInteger)index;

@end
