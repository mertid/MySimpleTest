//
//  TEALDatasourceStoreTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/6/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Tealium/TEALDatasourceStore.h>

@interface TEALDatasourceStoreTests : XCTestCase

@property (nonatomic, strong) TEALDatasourceStore *store;

@end

@implementation TEALDatasourceStoreTests

- (void)setUp {
    [super setUp];
    self.store = [[TEALDatasourceStore alloc] initWithInstanceID:@"tealiummobile_test_dev"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.store = nil;
    [super tearDown];
    
}

- (void) testUUID {
    NSString *uuid = [self.store applicationUUID];
    
    XCTAssertTrue(uuid, @"UUID was not created.");
    XCTAssertTrue([self acceptableUUID:uuid], @"Incorrect UUID format found: %@.", uuid);
}

#pragma mark - HELPERS

- (BOOL) acceptableUUID:(NSString *)uuid {
    
    NSError *regexError = nil;

    NSString *scriptContentsPattern = @"^[A-F0-9]{8}\\-([A-F0-9]{4}\\-){3}[A-F0-9]{12}$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:scriptContentsPattern
                                                                           options:0
                                                                             error:&regexError];
    if (!regex) {
        return NO;
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:uuid
                                                        options:0
                                                          range:NSMakeRange(0, [uuid length])];
    
    NSLog(@"%s Number of matches: %lu", __FUNCTION__, (unsigned long)numberOfMatches);
    
    if (numberOfMatches == 1) {
        return YES;
    }
    
    return NO;
}



@end
