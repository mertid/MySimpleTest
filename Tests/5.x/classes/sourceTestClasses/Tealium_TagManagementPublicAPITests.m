//
//  Tealium_TagManagementPublicAPITests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/22/16.
//
//

#import <XCTest/XCTest.h>
#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"
#import "Tealium+TagManagement.h"
#import "TEALTagDispatchService.h"

@interface Tealium_TagManagementPublicAPITests : XCTestCase

@property Tealium *library;

@end

@implementation Tealium_TagManagementPublicAPITests

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
    
}

- (TEALTagDispatchService*) tagManagementDispatchServiceInArray:(NSArray*)array {
    
    for (id dispatchService in array){
        
        if ([dispatchService isKindOfClass:[TEALTagDispatchService class]]){
            return dispatchService;
        }
        
    }
    
    return nil;
}

#pragma mark - PUBLIC API TESTS

- (void) testAddRemoteCommandBlock {
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"remoteCommand"];
    
    [self.library addRemoteCommandId:@"logger"
                         description:@""
                         targetQueue:dispatch_get_main_queue()
                               block:^(TEALRemoteCommandResponse * _Nullable response) {
                                   
                                   XCTAssertTrue(response, @"No response received.");
                                   
                                   NSDictionary *payload = response.requestPayload;
                                   
                                   XCTAssertTrue([payload[@"testKey"] isEqualToString:@"testValue"], @"Payload check failed: %@", payload);
                                   
                                   [expectation fulfill];
                                   
                               }];
    
    // Pause to let Tag Management spin up
    __block BOOL neverReady = NO;
    [TEALTestHelper waitFor:&neverReady timeout:1.0];
    
    NSArray *services = [self.library currentDispatchServices];
    
    TEALTagDispatchService *service = [self tagManagementDispatchServiceInArray:services];
    
    XCTAssertTrue(service, @"Tag Dispatch Service not yet ready.");
    
    [service.webView stringByEvaluatingJavaScriptFromString:@"window.open('tealium://logger?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}})), '_self');"];
    
    
    // Include wait time from above for Tag Management enablement
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    
}

#pragma mark - PRIVATE API TESTS


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
