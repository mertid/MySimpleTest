//
//  Tealium_CollectPublicAPITests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/22/16.
//
//

#import <XCTest/XCTest.h>
#import "Tealium+PrivateHeader.h"
#import "Tealium+Collect.h"
#import "TEALSettings+Collect.h"
#import "TEALTestHelper.h"

@interface Tealium_CollectPublicAPITests : XCTestCase

@property () Tealium *library;

@end

@implementation Tealium_CollectPublicAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    
    self.library = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    [Tealium destroyInstanceForKey:self.description];
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       XCTAssertTrue(success, @"Library failed to finish initializing - error:%@", error);
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
    isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        XCTAssertTrue(!error, @"Library failed to fetch test settings - error:%@", error);
        
        isReady = YES;
        
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
}

#pragma mark - PUBLIC API TESTS

- (void) testProfileURL {
    
        XCTFail(@"not yet implemented");
    
}

- (void) testProfileDefinitionURL {
    
        XCTFail(@"not yet implemented");
}

- (void) testCachedVisitorProfileCopy {
    
        XCTFail(@"not yet implemented");
}

- (void) testFetchVisitorProfileWithCompletion {
    
        XCTFail(@"not yet implemented");
    
}

#pragma mark - joinTraceWithToken:completion & leaveTrace TESTS

- (void) testJoinAndLeaveTrace {
    
    // Only tests if trace token set
    
    [Tealium destroyInstanceForKey:self.description];
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    
    NSString *token = @"A1B2C3";
    
    TEALSettings *settings = [self.library settings];
    
    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource should default to nil");
    
    [self.library joinTraceWithToken:token];
//    isReady = NO;
//    
//    [self.library joinTraceWithToken:token
//                          completion:^(BOOL success, NSError * _Nullable error) {
//                              
//                              XCTAssertTrue(success, @"Unexpected error in joining trace:%@", error);
//                              
//                              isReady = YES;
//                              
//                          }];
//    
//    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    NSString *traceId = [settings traceID];
    
    XCTAssertTrue(traceId, @"TraceID should have a value - %@ found.", traceId);
    
    XCTAssertTrue([traceId isEqualToString:token], @"TraceID value: %@ should be same as token passed in: %@", traceId, token);
    
    [self.library leaveTrace];
//    isReady = NO;
//    
//    [self.library leaveTraceWithCompletion:^(BOOL success, NSError *error) {
//        
//        isReady = YES;
//        
//    }];
//    
//    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource :%@ should now be nil", [settings traceID]);
    
}


//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
