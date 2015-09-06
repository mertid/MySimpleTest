//
//  TEALMobileCompanionContentSection.h
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALMobileCompanionContentRow;

@interface TEALMobileCompanionContentSection : NSObject


- (instancetype) initWithTitle:(NSString *)title rows:(NSArray *)rowData;

- (NSString *) title;

- (void) setTitle:(NSString *) title;

- (NSArray *) rowData;

- (void) addRow:(TEALMobileCompanionContentRow*) rowData;

@end
