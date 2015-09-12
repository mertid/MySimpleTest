//
//  TEALMobileCompanionContentRow.h
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TEALMobileCompanionContentRowType){
    TEALMobileCompanionContentRowTypeData,
    TEALMobileCompanionContentRowTypeTool
};

@interface TEALMobileCompanionContentRow : NSObject

- (instancetype) initWithKey:(NSString *)key value:(NSString *)value;
- (instancetype) initWithValueOnly:(NSString *)valueOnly;

- (NSString *) keyValue;

- (void) setType:(TEALMobileCompanionContentRowType)type;
- (void) addButton:(UIButton*)button;

@end
