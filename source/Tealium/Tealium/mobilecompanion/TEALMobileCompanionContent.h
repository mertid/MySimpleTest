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

- (void) addSectionAndRowDataFromDictionary:(NSDictionary *)dictionary;

- (NSArray *) headerTitles;

- (NSArray *) rowDataForSectionIndex:(NSInteger)index;

- (NSString *) keyForIndex:(NSIndexPath *)indexPath;

- (NSString *) valueForIndex:(NSIndexPath *)indexPath;

@end
