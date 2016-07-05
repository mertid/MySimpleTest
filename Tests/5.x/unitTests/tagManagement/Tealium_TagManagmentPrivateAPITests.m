//
//  Tealium_TagManagmentPrivateAPITests.m
//  FrameworkBuilder
//
//  Created by Jason Koo on 6/7/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tealium+PrivateHeader.h"
#import "TEALTestHelper.h"

@interface Tealium_TagManagmentPrivateAPITests : XCTestCase <TealiumDelegate>

@end

@implementation Tealium_TagManagmentPrivateAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (Tealium*) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    NSString *testID = @"collectConfigurationTests";
    
    [Tealium destroyInstanceForKey:testID];
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    Tealium *library = [Tealium newInstanceForKey:testID
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       XCTAssertTrue(success, @"Library failed to finish initializing - error:%@", error);
                                       
                                       isReady = YES;
                                       
                                   }];
    
    [library setDelegate:self];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
    return library;
    
}

#pragma mark - TESTS

- (void) testTagManagementDispatchServiceReady {
    
    // Create tealium instance
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"tag_management_ON"];

    Tealium *tealium = [self enableLibraryWithConfiguration:config];
    
    BOOL waiting = false;
    
    // Give the startup sequence a second to complete
    [TEALTestHelper waitFor:&waiting timeout:1.0];

    // run protocol check to see if bool false returned from check
    NSError *error;
    
    BOOL canSend = [tealium dispatchManagerShouldDispatch:&error];
    
    XCTAssertTrue(canSend == true, @"Dispatch manager should have return true.");
    
}


#pragma mark - TEALIUM DELEGATE



#pragma mark - UNUSED

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
