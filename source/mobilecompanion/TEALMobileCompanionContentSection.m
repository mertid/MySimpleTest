//
//  TEALMobileCompanionContentSection.m
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanionContentSection.h"
#import "TEALMobileCompanionContentRow.h"

@interface TEALMobileCompanionContentSection()

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSArray *currentRows;

@end

@implementation TEALMobileCompanionContentSection

- (instancetype) initWithTitle:(NSString *)title rows:(NSArray *)rowData {
    self = [super init];
    if (self) {
        
        _currentTitle = title;
        _currentRows = rowData;
    }
    
    return self;
}

- (NSString *) title {
    return [self.currentTitle copy];
}

- (void) setTitle:(NSString *) title {
    self.currentTitle = title;
}


- (NSArray *) rowData {
    
    return [self.currentRows copy];

}

- (void) addRow:(TEALMobileCompanionContentRow *)rowData {
    
    NSMutableArray *newRowData = [NSMutableArray arrayWithArray:[self.currentRows copy]];
    
    [newRowData addObject:rowData];
    
    self.currentRows = [NSArray arrayWithArray:newRowData];
    
}

@end
