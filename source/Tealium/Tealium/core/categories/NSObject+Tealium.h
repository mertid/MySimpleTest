//
//  NSObject+TealiumAdditions.h
//  TealiumUtilities
//
//  Created by George Webster on 2/12/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Tealium)

- (NSDictionary *) teal_dataSources;
- (void) teal_setDataSources:(NSDictionary *)dataSources;
- (NSString *) teal_stringValue;



@end
