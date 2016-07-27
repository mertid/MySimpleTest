//
//  TEALS2SLegacyDispatchServiceTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 2/10/16.
//
//

#import <XCTest/XCTest.h>
#import "TEALDispatch+PrivateHeader.h"
#import "TEALS2SLegacyDispatchService.h"
#import "TEALURLSessionManager.h"
#import "TEALError.h"

@interface TEALS2SLegacyDispatchServiceTests : XCTestCase

@property TEALS2SLegacyDispatchService *service;
@property TEALURLSessionManager *sessionManager;

@end

@implementation TEALS2SLegacyDispatchServiceTests

- (void)setUp {
    [super setUp];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.sessionManager = [[TEALURLSessionManager alloc] initWithConfiguration:config];

    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {

    self.service = nil;
    self.sessionManager = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - TESTS

/*
 Sample encoded output for account - tealiummobile
 
 @"https://collect.tealiumiq.com/tealiummobile/main/8/i.gif?data=%7B%22data%22%3A%7B%22device_battery_percent%22%3A%22-100%22,%22link_id%22%3A%22launch%22,%22event_name%22%3A%22mobile_link%22,%22app_name%22%3A%22UIKitCatalog%22,%22device_os_version%22%3A%229.0%22,%22app_version%22%3A%2212.0%22,%22device_language%22%3A%22en-US%22,%22connection_type%22%3A%22wifi%22,%22timestamp_offset%22%3A%22-8%22,%22library_version%22%3A%225.0.0%22,%22uuid%22%3A%22749C7B66-65E5-49A3-83EB-5F61D5E523B9%22,%22device_ischarging%22%3A%22false%22,%22origin%22%3A%22mobile%22,%22timestamp_local%22%3A%222016-02-10T07%3A07%3A40%22,%22visitor_id%22%3A%22749C7B6665E549A383EB5F61D5E523B9%22,%22call_type%22%3A%22link%22,%22was_queued%22%3A%22false%22,%22device_cputype%22%3A%22x86%20%22,%22resolution%22%3A%223x2%22,%22platform%22%3A%22iOS%22,%22dom.domain%22%3A%22tealium.com%22,%22orientation%22%3A%22Portrait%22,%22device_orientation%22%3A%22Portrait%22,%22app_rdns%22%3A%22com.example.apple-samplecode.UIKitCatalog%22,%22timestamp%22%3A%222016-02-10T15%3A07%3A40Z%22,%22os_version%22%3A%229.0%22,%22device_resolution%22%3A%22750x1334%22,%22launches%22%3A1,%22cp.utag_main_v_id%22%3A%22749C7B6665E549A383EB5F61D5E523B9%22,%22device_architecture%22%3A%2264%22,%22timestamp_unix%22%3A%221455116860%22,%22device%22%3A%22Simulator%22%7D%7D"
 */



- (void) testRequestForDispatchWithDispatchString {
    
    NSString * dispatchString = @"https://www.test.com";
    NSString * visitorID = @"12345678";
    
    self.service = [[TEALS2SLegacyDispatchService alloc]initWithDispatchURLString:dispatchString
                                                                        visitorID:visitorID
                                                                   sessionManager:self.sessionManager];
    
    NSDictionary *payload = @{
                              
                              };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:payload];
    
    XCTAssertTrue(dispatch, @"Test dispatch was not created.");
    
    XCTAssertTrue(self.service, @"Test S2SLegacyDispatchService did not init.");
    
    NSError *error = nil;
    
    NSURLRequest *request = [self.service requestForDispatch:dispatch error:&error];
    
    NSLog(@"%s request: %@", __FUNCTION__, request);
    
    XCTAssertTrue(!error, @"Unexpected error: %@", error);
    
    XCTAssertTrue(request, @"No request generated");
    
    XCTAssertTrue([request.URL.absoluteString containsString:@"?"], @"Incorrectly formatted url string: %@", request.URL.absoluteString);
    
}

- (void) testRequestForDispatchWithDispatchStringWithQuestionMark {
    
    NSString * dispatchString = @"https://www.test.com?";
    NSString * visitorID = @"12345678";
    
    self.service = [[TEALS2SLegacyDispatchService alloc]initWithDispatchURLString:dispatchString
                                                                        visitorID:visitorID
                                                                   sessionManager:self.sessionManager];
    
    NSDictionary *payload = @{
                              
                              };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:payload];
    
    XCTAssertTrue(dispatch, @"Test dispatch was not created.");
    
    XCTAssertTrue(self.service, @"Test S2SLegacyDispatchService did not init.");
    
    NSError *error = nil;
    
    NSURLRequest *request = [self.service requestForDispatch:dispatch error:&error];
    
    NSLog(@"%s request: %@", __FUNCTION__, request);
    
    XCTAssertTrue(!error, @"Unexpected error: %@", error);
    
    XCTAssertTrue(request, @"No request generated");
    
    XCTAssertTrue([request.URL.absoluteString containsString:@"?"], @"Incorrectly formatted url string: %@", request.URL.absoluteString);
    
}

- (void) testSendDispatchWithMissingDispatchString {
    
    NSString * dispatchString = nil;
    
    NSString * visitorID = @"12345678";
    
    self.service = [[TEALS2SLegacyDispatchService alloc]initWithDispatchURLString:dispatchString
                                                                        visitorID:visitorID
                                                                   sessionManager:self.sessionManager];
    
    NSDictionary *payload = @{
                              
                              };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:payload];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"s2sLegacyMissingDispatchString"];
    
    __block TEALDispatchStatus dispatchStatus;
    __block NSError *dispatchError = nil;
    
    [self.service sendDispatch:dispatch
completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
    
    dispatchStatus = status;
    
    dispatchError = error;
    
    [expectation fulfill];
}];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(dispatchStatus == TEALDispatchStatusFailed, @"Unexpected return status: %@", [TEALDispatch stringFromDispatchStatus:dispatchStatus]);
    
    XCTAssertTrue(dispatchError, @"No error when error expected.");
    
    XCTAssertTrue(dispatchError.code == TEALErrorCodeException, @"Unexpected error code received: %li", (long)dispatchError.code);
    
    
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
