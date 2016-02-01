//
//  TEALMobileCompanionContentRow.m
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanionContentRow.h"

@interface TEALMobileCompanionContentRow()

@property (nonatomic, strong) NSString *instanceKey;
@property (nonatomic, strong) NSString *instanceValue;
@property (nonatomic, strong) NSString *instantceValueOnly;
@property (atomic) TEALMobileCompanionContentRowType instanceType;

@end


@implementation TEALMobileCompanionContentRow

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithKey:(NSString *)key value:(NSString *)value {
    self = [super init];
    if (self) {
     
        _instanceKey = [key isKindOfClass:([NSString class])]? key:nil;
        _instanceValue = [value isKindOfClass:([NSString class])]? value:nil;
        _instanceType = TEALMobileCompanionContentRowTypeData;
        
    }
    
    return self;
}

- (instancetype) initWithValueOnly:(NSString *)valueOnly {
    self = [super init];
    if (self) {
        
        _instantceValueOnly = [valueOnly isKindOfClass:([NSString class])]? valueOnly:nil;
        _instanceType = TEALMobileCompanionContentRowTypeData;

    }
    
    return self;
}



- (NSString *) keyValue {
    
    NSString *key = self.instanceKey;
    NSString *value = self.instanceValue;
    
    if (self.instantceValueOnly) {
        return self.instantceValueOnly;
    }
    
    if (key || value) {
        
        NSString *space = @"";
        
        if (key && value){
            space = @" ";
        }
        return [NSString stringWithFormat:@"%@%@%@", key?key:@"", space, value?value:@""];
    }
    
    return @"";
}

- (void) setType:(TEALMobileCompanionContentRowType)type {
 
    self.instanceType = type;

}

- (void) addButton:(UIButton*)button {
    
}


#pragma mark - PRIVATE INSTANCE

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: keyValue:%@",
            NSStringFromClass([self class]),
            [self keyValue]];
}
@end
