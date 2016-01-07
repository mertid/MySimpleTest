//
//  TEALMobileCompanionContent.m
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanionContent.h"
#import "TEALMobileCompanionContentRow.h"
#import "TEALMobileCompanionContentSection.h"

@interface TEALMobileCompanionContent()

@property (nonatomic, strong) NSArray *instanceSectionData;
@property (nonatomic) TEALMobileCompanionContentType *privateType;

@end

@implementation TEALMobileCompanionContent

+ (TEALMobileCompanionContent *) contentFromArray:(NSArray *)array {

    TEALMobileCompanionContent *newContent = [[TEALMobileCompanionContent alloc] init];
    
    [newContent addSectionAndRowDataFromArray:array];
    
    return newContent;
}

- (void) addSectionAndRowDataFromArray:(NSArray *)array {
    
    // Take all keys as section titles
    // Take all values (array of dicts where keys are row keys and values are row values
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (![obj isKindOfClass:([NSDictionary class])]) {
            return;
        }
        
        NSDictionary *dict = (NSDictionary *)obj;
        
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *sectionKey = key;
            NSMutableArray *rowData = [NSMutableArray array];
            
            NSArray *rawRowData = (NSArray*)obj;
            
            if ([rawRowData respondsToSelector:@selector(enumerateObjectsUsingBlock:)]){
                        
                for (id rawRow in rawRowData) {
                    
                    __block TEALMobileCompanionContentRow *newRow = nil;
                    
                    if ([rawRow isKindOfClass:([NSDictionary class])]){
                        
                        NSDictionary *rowDict = (NSDictionary *)rawRow;
                        
                        [rowDict enumerateKeysAndObjectsUsingBlock:^(id rowKey, id rowValue, BOOL *rowStop) {
                            
                            // Should be data for only 1 row, but will add additional keys if needed
                            
                            newRow = [[TEALMobileCompanionContentRow alloc] initWithKey:rowKey value:rowValue];
                            [rowData addObject:newRow];
                            
                        }];
                    }
                    
                    if ([rawRow isKindOfClass:([NSString class])]) {
                        
                        NSString *rowValue = (NSString *)rawRow;
                        newRow = [[TEALMobileCompanionContentRow alloc] initWithValueOnly:rowValue];
                        [rowData addObject:newRow];
                        
                    }
                }
            }
            
            TEALMobileCompanionContentSection *newSection = [[TEALMobileCompanionContentSection alloc] initWithTitle:sectionKey rows:[NSArray arrayWithArray:rowData]];
            
            [self addSectionData:newSection];
        }];
        
    }];
    
}
- (void) setType:(TEALMobileCompanionContentType)type {
    
    self.privateType = &(type);
    
}

- (TEALMobileCompanionContentType) type {
 
    if (self.privateType) return *(self.privateType);
    return TEALMobileCompanionContentTypeNormal;
}

- (void) addSectionData:(TEALMobileCompanionContentSection *)section {

    NSMutableArray *newSectionData = [NSMutableArray arrayWithArray:[self sectionData]];
    [newSectionData addObject:section];
    
    self.instanceSectionData = [NSArray arrayWithArray:newSectionData];
    
}

- (NSArray *) sectionData {
    
    if (!self.instanceSectionData) {
        self.instanceSectionData = [NSArray array];
    }
    return [self.instanceSectionData copy];
    
}


- (NSArray *) headerTitles {
    
    NSMutableArray *titles = [NSMutableArray array];
    
    for (TEALMobileCompanionContentSection *section in [self.instanceSectionData copy]){
        [titles addObject:section.title];
    }
    
    return [NSArray arrayWithArray:titles];
    
}

- (NSArray *) rowDataForSectionIndex:(NSInteger)index {
    
    TEALMobileCompanionContentSection *targetSection = [self.instanceSectionData copy][index];
    
    return [targetSection rowData];
}

@end
