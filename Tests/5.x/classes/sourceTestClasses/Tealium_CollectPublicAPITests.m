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

@interface Tealium_CollectPublicAPITests : XCTestCase<TealiumDelegate>

@property Tealium *library;
@property BOOL didFetch;
@end

@implementation Tealium_CollectPublicAPITests

- (void)setUp {
    [super setUp];
    self.didFetch = NO;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    
    self.library = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    NSString *testID = @"collectConfigurationTests";
    
    [Tealium destroyInstanceForKey:testID];
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:testID
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       XCTAssertTrue(success, @"Library failed to finish initializing - error:%@", error);
                                       
                                       isReady = YES;
                                       
                                   }];
    
    [self.library setDelegate:self];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
}

#pragma mark - PUBLIC API TESTS

- (void) testProfileURL {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    [self enableLibraryWithConfiguration:config];
    
    // Buffer
    BOOL waiting = NO;
    [TEALTestHelper waitFor:&waiting timeout:1.0];
    
    NSString *profileURL = [[self.library profileURL] absoluteString];
    
    NSString *visitorID = [self.library visitorIDCopy];
    
    XCTAssertTrue(visitorID, @"Visitor ID missing.");
    
    NSString *expectedURLString = [NSString stringWithFormat:@"https://visitor-service.tealiumiq.com/%@/main/%@", config.accountName, visitorID];
    
    XCTAssertTrue([profileURL isEqualToString:expectedURLString], @"profileURL: %@ did not match expected url: %@", profileURL, expectedURLString);
    
}

- (void) testProfileDefinitionURL {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    [self enableLibraryWithConfiguration:config];
    
    // Buffer
    BOOL waiting = NO;
    [TEALTestHelper waitFor:&waiting timeout:1.0];
    
    NSString *profileDefintionsURL = [[self.library profileDefinitionURL] absoluteString];
    
    NSString *expectedURLString = [NSString stringWithFormat:@"https://visitor-service.tealiumiq.com/datacloudprofiledefinitions/%@/main", config.accountName];
    
    XCTAssertTrue([profileDefintionsURL isEqualToString:expectedURLString], @"profileDefinitionURL: %@ did not match expected url: %@", profileDefintionsURL, expectedURLString);
    
}

- (void) testFetchVisitorProfileWithCompletionAndCachedVisitorProfile {
    
    // !!! This test only passes if run individually or as part of this unit test class
    //  - always fails if ran with all other unit tests, reason unknown.
    
    // Test Tealium instance setup
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    NSString *testID = @"fetchVisitorTest";
    
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
    
    
    // Fetch visitor profile calls
    XCTestExpectation *expectationInitial = [self expectationWithDescription:@"fetchVisitorProfileInitial"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchVisitorProfile"];

    __block TEALVisitorProfile *fetchProfile = nil;
    __block NSError *fetchError = nil;
    
    [library fetchVisitorProfileWithCompletion:^(TEALVisitorProfile * _Nullable profile, NSError * _Nullable error) {
    
        if (!fetchProfile){
            fetchProfile = profile;
        }
        
        if (!fetchError){
            fetchError = error;
        }
        
        [expectationInitial fulfill];
        
    }];

    // Do this twice as first call may return nothing
    
    [library fetchVisitorProfileWithCompletion:^(TEALVisitorProfile * _Nullable profile, NSError * _Nullable error) {
        
        if (!fetchProfile){
            fetchProfile = profile;
        }
        
        if (!fetchError){
            fetchError = error;
        }
        
        [expectation fulfill];
        
    }];
        
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
    // Check Tealium instance for cached profile
    TEALVisitorProfile *cachedProfile = [
                                         library cachedVisitorProfileCopy];
    
    XCTAssertTrue(cachedProfile, "No cached profile found.");
    
    XCTAssertTrue(fetchProfile, @"No profile returned.");
    
    XCTAssertTrue(!fetchError, @"Error detected: %@.", fetchError);
}

#pragma mark - joinTraceWithToken:completion & leaveTrace TESTS

- (void) testJoinAndLeaveTrace {
    
    // Only tests if trace token set
    
    [Tealium destroyInstanceForKey:self.description];
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    NSString *token = @"A1B2C3";
    
    NSString *startTraceID = [self.library volatileDataSourcesCopy][TEALDataSourceKey_TraceID];
    
    XCTAssertTrue(startTraceID == nil, @"TraceID datasource should start empty");
    
    __block NSString * traceID = nil;
    __block BOOL addSuccess = NO;
    __block NSError *addError = nil;
    __block typeof(self) __weak weakSelf = self;

    XCTestExpectation *expectation = [self expectationWithDescription:@"setTraceID"];
    
    // Same as - [self.library joinTraceWithToken:token];
    [self.library addVolatileDataSources:@{TEALDataSourceKey_TraceID:token} completion:^(BOOL success, NSError * _Nullable error) {
        
        addSuccess = success;
        
        addError = error;

        [expectation fulfill];
        
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(addSuccess, @"Unexpected error:%@", addError);
    
    traceID = [weakSelf.library volatileDataSourcesCopy][TEALDataSourceKey_TraceID];
    
    XCTAssertTrue(traceID, @"TraceID should have a value - %@ found.", traceID);
    
    XCTAssertTrue([traceID isEqualToString:token], @"TraceID value: %@ should be same as token passed in: %@", traceID, token);
    
    isReady = NO;
    
    // Same as - [self.library leaveTrace];
    [self.library removeVolatileDataSourcesForKeys:@[TEALDataSourceKey_TraceID]
                                        completion:^(BOOL success, NSError * _Nullable error) {
                                            
                                            XCTAssertTrue(success, @"Unexpected error: %@", error);
                                            
                                            isReady = YES;
                                            
                                        }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}

    NSString *postTraceID = [self.library volatileDataSourcesCopy][TEALDataSourceKey_TraceID];

    XCTAssertTrue(postTraceID == nil, @"TraceID datasource :%@ should now be nil", postTraceID);
    
}


#pragma mark - TEALIUM DELEGATE

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    self.didFetch = YES;
    
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
