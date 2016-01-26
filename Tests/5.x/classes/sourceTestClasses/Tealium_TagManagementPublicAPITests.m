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

- (void) testAddAndExecuteRemoteCommandBlock {
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    XCTestExpectation *expectationAddCommand = [self expectationWithDescription:@"remoteCommandAdded"];
    
    __block BOOL hasExecuted = NO;
    __block TEALRemoteCommandResponse *blockResponse = nil;
    __block TEALTagDispatchService *blockTagDispatchService = nil;
    __block NSError *completionError = nil;
    
    blockTagDispatchService = [self.library currentTagDispatchService];
    
    [[self.library remoteCommandManager] enable];
    
    XCTAssertTrue([[self.library remoteCommandManager] isEnabled], @"Remote command manager NOT enabled.");
    
    [self.library addRemoteCommandID:@"test"
                         description:nil
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
                           if (response.status == 200){
                            
                               blockResponse = response;
                               
                               hasExecuted = YES;
                               
                           }
                           
                       } completion:^(BOOL success, NSError * _Nullable error) {
                           
                           completionError = error;
                           
                           [expectationAddCommand fulfill];

                       }];

    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(!completionError, @"Unexpected error when adding remote command block: %@", completionError);
    
    // Execute the call

    XCTAssertTrue(blockTagDispatchService.webView, @"Webview not ready.");
    
//    dispatch_async(dispatch_get_main_queue(), ^{
    
        [blockTagDispatchService.webView stringByEvaluatingJavaScriptFromString:@"window.open('tealium://test?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}})), '_self');"];
        
//    });
    
    [TEALTestHelper waitFor:&hasExecuted timeout:3.0];
    
    // Check response
    
    XCTAssertTrue(hasExecuted, @"Response never triggered.");
    
    XCTAssertTrue(blockResponse, @"No response received.");
    
    NSDictionary *payload = blockResponse.requestPayload;
    
    XCTAssertTrue([payload[@"testKey"] isEqualToString:@"testValue"], @"Payload check failed: %@", payload);
    
    XCTAssertTrue(blockTagDispatchService, @"Tag Dispatch Service never became available.");
    
    
}

#pragma mark - PRIVATE API TESTS

- (void) testRemoveCommandBlockFromRemoteCommandManager {
    
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    XCTestExpectation *expectationCallSent = [self expectationWithDescription:@"remoteCommandExecute"];
    XCTestExpectation *expectationRemoval = [self expectationWithDescription:@"remoteCommandRemove"];

    
    __block typeof(self) __weak weakSelf = self;
    __block TEALRemoteCommandResponse *weakResponse = nil;
    __block TEALTagDispatchService *weakService = nil;
    __block BOOL didRemove = NO;
    __block NSError *weakAddError = nil;
    __block NSError *weakRemovalError = nil;
    
    [self.library addRemoteCommandID:@"test"
                         description:@""
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
           // Should not get a response
           weakResponse = response;
                           
           
       } completion:^(BOOL success, NSError * _Nullable error) {
           
           // Going to immediately remove
           weakAddError = error;
           
           [weakSelf.library removeRemoteCommandID:@"logger"
                                        completion:^(BOOL success, NSError * _Nullable error) {
                                            
                                            didRemove = success;
                                            weakRemovalError = error;
                                            
                                            [expectationRemoval fulfill];
                                            
                                            // Make a call to see what happens
                                            weakService = [weakSelf.library currentTagDispatchService];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [weakService.webView stringByEvaluatingJavaScriptFromString:@"window.open('tealium://logger?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}})), '_self');"];
                                                
                                                [expectationCallSent fulfill];
                                                
                                            });
                                            
                                        }];
           
       }];

    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
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
