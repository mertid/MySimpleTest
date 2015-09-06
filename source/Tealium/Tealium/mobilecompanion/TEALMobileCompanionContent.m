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

@end

@implementation TEALMobileCompanionContent


- (void) addSectionAndRowDataFromDictionary:(NSDictionary *)dictionary {
    
    // Take all keys as section titles
    // Take all values (array of dicts where keys are row keys and values are row values
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        
        if (![key isKindOfClass:([NSString class])]){
            return;
        }
        
        NSString *sectionKey = key;
        NSMutableArray *rowData = [NSMutableArray array];
        
        NSArray *rawRowData = (NSArray*)obj;
        
            NSLog(@"%s obj:%@", __FUNCTION__, obj);
        
        for (NSDictionary *rowDict in rawRowData) {
            
            if (![rowDict isKindOfClass:([NSDictionary class])]){
                break;
            }
            
            [rowDict enumerateKeysAndObjectsUsingBlock:^(id rowKey, id rowValue, BOOL *rowStop) {

                // Should only be one, but will add additional keys if needed
                
                TEALMobileCompanionContentRow *newRow = [[TEALMobileCompanionContentRow alloc] init];
                newRow.key = [rowKey isKindOfClass:([NSString class])]? rowKey : nil;
                newRow.value = [rowValue isKindOfClass:([NSString class])]? rowValue : nil;
                [rowData addObject:newRow];
                
            }];
            
        }
        
        TEALMobileCompanionContentSection *newSection = [[TEALMobileCompanionContentSection alloc] initWithTitle:sectionKey rows:[NSArray arrayWithArray:rowData]];

        [self addSectionData:newSection];
        
    }];
    
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

- (NSString *) keyForIndex:(NSIndexPath *)indexPath {
    
    NSArray *rowData = [self rowDataForSectionIndex:indexPath.section];
    
    TEALMobileCompanionContentRow *row = rowData[indexPath.row];
    
    return row.key;
}

- (NSString *) valueForIndex:(NSIndexPath *)indexPath {
    
    NSArray *rowData = [self rowDataForSectionIndex:indexPath.section];
    
    TEALMobileCompanionContentRow *row = rowData[indexPath.row];
    
    return row.value;
}

@end
