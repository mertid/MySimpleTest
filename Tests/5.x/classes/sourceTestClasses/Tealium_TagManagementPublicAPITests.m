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
#import "Tealium+TagManagement+PrivateHeader.h"
#import "TEALTagDispatchService.h"
#import "TEALRemoteCommand.h"

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
    
    NSString *testID = @"CollectAPITests";
    
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
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
}

//- (TEALTagDispatchService*) tagManagementDispatchServiceInArray:(NSArray*)array {
//    
//    for (id dispatchService in array){
//        
//        if ([dispatchService isKindOfClass:[TEALTagDispatchService class]]){
//            return dispatchService;
//        }
//        
//    }
//    
//    return nil;
//}

#pragma mark - PUBLIC API TESTS

- (void) testAddSingleRemoteCommandBlock {
  
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];

    XCTestExpectation *expectationAddCommand = [self expectationWithDescription:@"remoteCommandAdded"];

    __block NSError *completionError = nil;

    __block TEALTagDispatchService *blockTagDispatchService = [self.library newTagDispatchService];
    
    [self.library addNewDispatchService:blockTagDispatchService];

    XCTAssertTrue([self.library remoteCommandManager], @"Remote command manager NOT available.");
    
    // First add the remote command to the tealium instance
    [self.library addRemoteCommandID:@"test"
                         description:nil
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {

                           // Ignoring any responses for this test

                       } completion:^(BOOL success, NSError * _Nullable error) {

                           completionError = error;

                           [expectationAddCommand fulfill];

                       }];

    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(blockTagDispatchService, @"Tag Dispatch Service did not enable.");

    XCTAssertTrue(!completionError, "Unexpected problem adding remote command:%@", completionError);
    
    
}


- (void) testAddMultpleRemoteCommandBlocks {
    
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    XCTestExpectation *expectationAddCommandAlpha = [self expectationWithDescription:@"remoteCommandAddedAlpha"];
    XCTestExpectation *expectationAddCommandBravo = [self expectationWithDescription:@"remoteCommandAddedBravo"];
    XCTestExpectation *expectationAddCommandCharlie = [self expectationWithDescription:@"remoteCommandAddedCharlie"];

    
    __block NSError *completionErrorAlpha = nil;
    __block NSError *completionErrorBravo = nil;
    __block NSError *completionErrorCharlie = nil;
    
    TEALTagDispatchService *blockTagDispatchService = [self.library newTagDispatchService];
    [self.library addNewDispatchService:blockTagDispatchService];
    
    XCTAssertTrue([self.library remoteCommandManager], @"Remote command manager NOT available.");
    
    // First add the remote command to the tealium instance
    [self.library addRemoteCommandID:@"alpha"
                         description:nil
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
                           // Ignoring any responses for this test
                           
                       } completion:^(BOOL success, NSError * _Nullable error) {
                           
                           completionErrorAlpha = error;
                           
                           [expectationAddCommandAlpha fulfill];
                           
                       }];
    
    [self.library addRemoteCommandID:@"bravo"
                         description:nil
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
                           // Ignoring any responses for this test
                           
                       } completion:^(BOOL success, NSError * _Nullable error) {
                           
                           completionErrorBravo = error;
                           
                           [expectationAddCommandBravo fulfill];
                           
                       }];
    
    [self.library addRemoteCommandID:@"charlie"
                         description:nil
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
                           // Ignoring any responses for this test
                           
                       } completion:^(BOOL success, NSError * _Nullable error) {
                           
                           completionErrorCharlie = error;
                           
                           [expectationAddCommandCharlie fulfill];
                           
                       }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(blockTagDispatchService, @"Tag Dispatch Service did not enable.");

    XCTAssertTrue(!completionErrorAlpha, "Unexpected problem adding remote command:%@", completionErrorAlpha);
    
    
}

//- (void) testAddAndExecuteRemoteCommandBlock {
//    
//    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
//    
//    XCTestExpectation *expectationAddCommand = [self expectationWithDescription:@"remoteCommandAdded"];
//    
//    __block BOOL hasExecuted = NO;
//    __block TEALRemoteCommandResponse *blockResponse = nil;
//    __block TEALTagDispatchService *blockTagDispatchService = nil;
//    __block NSError *completionError = nil;
//    
//    blockTagDispatchService = [self.library currentTagDispatchService];
//    
//    [[self.library remoteCommandManager] enable];
//    
//    XCTAssertTrue([[self.library remoteCommandManager] isEnabled], @"Remote command manager NOT enabled.");
//    XCTAssertTrue(blockTagDispatchService, @"Tag Management dispatch service not ready.");
//    
//    // First add the remote command to the tealium instance
//    [self.library addRemoteCommandID:@"alpha"
//                         description:nil
//                         targetQueue:dispatch_get_main_queue()
//                       responseBlock:^(TEALRemoteCommandResponse *response) {
//                           
//                           if (response.status == 200){
//                            
//                               blockResponse = response;
//                               
//                               hasExecuted = YES;
//                               
//                           }
//                           
//                       } completion:^(BOOL success, NSError * _Nullable error) {
//                           
//                           completionError = error;
//                           
//                           [expectationAddCommand fulfill];
//
//                       }];
//
//    
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
//    
//    XCTAssertTrue(!completionError, @"Unexpected error when adding remote command block: %@", completionError);
//    
//    // Second execute a call to trigger the command block
//
//    XCTAssertTrue(blockTagDispatchService.webView, @"Webview not ready.");
//    
//    [blockTagDispatchService.webView stringByEvaluatingJavaScriptFromString:@"window.open('tealium://test?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"alpha\"},payload : {testKey : \"testValue\"}})), '_self');"];
//        
//    
//    [TEALTestHelper waitFor:&hasExecuted timeout:3.0];
//    
//    // Check response
//    
//    XCTAssertTrue(hasExecuted, @"Response never triggered.");
//    
//    XCTAssertTrue(blockResponse, @"No response received.");
//    
//    NSDictionary *payload = blockResponse.requestPayload;
//    
//    XCTAssertTrue([payload[@"testKey"] isEqualToString:@"testValue"], @"Payload check failed: %@", payload);
//    
//    XCTAssertTrue(blockTagDispatchService, @"Tag Dispatch Service never became available.");
//    
//    
//}

#pragma mark - PRIVATE API TESTS

- (void) testRemoveCommandBlockFromRemoteCommandManager {
    
    // This test only passes individually - multithreading issue?
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    XCTestExpectation *expectationAdd = [self expectationWithDescription:@"remoteCommandAdded"];
    
    __block TEALRemoteCommandResponse *weakResponse = nil;
    __block TEALTagDispatchService *weakService = [self.library newTagDispatchService];
    [self.library addNewDispatchService:weakService];
    
    __block BOOL didRemove = NO;
    __block NSError *weakAddError = nil;
    __block NSError *weakRemovalError = nil;
    
    NSString *commandID = @"test";
    
    [self.library addRemoteCommandID:commandID
                         description:@""
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
           // Should not get a response
           weakResponse = response;
                           
           
       } completion:^(BOOL success, NSError * _Nullable error) {
           
           // Going to immediately remove
           weakAddError = error;
           
           [expectationAdd fulfill];
           
       }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    TEALRemoteCommand *command = [self.library.remoteCommandManager commands][commandID];

    XCTAssertTrue(command, @"Added command missing: %@", [self.library.remoteCommandManager commands]);
    
    __block BOOL removeFinished = NO;
    
    [self.library removeRemoteCommandID:commandID
                                 completion:^(BOOL success, NSError * _Nullable error) {
                                     
                                     didRemove = success;
                                     weakRemovalError = error;
                                     
                                     removeFinished = YES;
                                     
                                 }];
    
    
    //+ (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs;

    [TEALTestHelper waitFor:&removeFinished timeout:1.0];
    
    command = [self.library.remoteCommandManager commands][commandID];

    XCTAssertTrue(!command, @"Command was not removed: %@", command);
    
    XCTAssertTrue(!weakResponse, @"Unexpected response detected: %@", weakResponse);
    
    XCTAssertTrue(!weakAddError, @"Unexpected error in adding command block detected: %@", weakAddError);
    
    XCTAssertTrue(weakService, @"Tag Management Dispatch Service was not found.");
    
}

- (NSString *) testTagBridgeURLString {
    
    return @"window.open('tealium://logger?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}})), '_self');";
    
    
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
