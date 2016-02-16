//
//  TEALRemoteCommandManagerTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/25/16.
//
//

#import <XCTest/XCTest.h>
#import "TEALRemoteCommandManager.h"
#import "TEALOperationManager.h"
#import "TEALTestHelper.h"

@interface TEALRemoteCommandManagerTests : XCTestCase

@property TEALRemoteCommandManager *manager;
@property TEALOperationManager *operationManager;

@end

@implementation TEALRemoteCommandManagerTests

- (void)setUp {
    [super setUp];
    
    self.operationManager = [[TEALOperationManager alloc] initWithInstanceID:@"testInstance"];
    self.manager = [[TEALRemoteCommandManager alloc]initWithOperationManager:self.operationManager];
    
}

- (void)tearDown {
    self.manager = nil;
    [super tearDown];
}

- (NSString *) commandID {
    
    return @"test";
}

- (NSString *) tagBridgeCommandString {

    return [NSString stringWithFormat:@"%@?request={config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}}))", [self commandID]];
}

- (NSString *) tagBridgeURLString {
    
    return [NSString stringWithFormat:@"tealium://%@", [self tagBridgeCommandString]];
    
}

- (void) testExtractCommandStringsFromURL {
    
    NSString *fullURLString = [self tagBridgeURLString];
    
    NSError *error = nil;
    
    NSString *commandString = [TEALRemoteCommandManager commandStringFromURLString:fullURLString error:error];
    
    NSString *commandID = [TEALRemoteCommandManager commandIDFromCommandString:commandString];
    
    XCTAssertTrue(!error, @"Unexpected error encountered: %@", error);
    
    XCTAssertTrue([commandString isEqualToString:[self tagBridgeCommandString]], @"Extracted command string not as expected: %@", commandString);
    
    XCTAssertTrue([commandID isEqualToString:[self commandID]], @"Command id not as expected: %@", commandID);
    
}

- (void) testAddRemoteCommand {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"addRemoteCommand."];
    
    __block NSError *completionError = nil;
    __block BOOL completionSuccess = NO;
    
    [self.manager addRemoteCommandID:@"test"
                         description:@"testDescription"
                         targetQueue:dispatch_get_main_queue()
                       responseBlock:^(TEALRemoteCommandResponse *response) {
                           
                       } completion:^(BOOL success, NSError * _Nullable error) {
                           
                           completionError = error;
                           completionSuccess = success;
                           
                           [expectation fulfill];
                           
                       }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(!completionError, @"Unexpected completion error: %@", completionError);
    
    XCTAssertTrue(completionSuccess, @"Adding remote commmand was not successful.");
}


//- (void) testTriggerRemoteCommand {
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"addRemoteCommand."];
//    __block NSError *completionError = nil;
//    __block BOOL completionSuccess = NO;
//    __block BOOL responseBlockReceived = NO;
//    NSString *commandString = [self tagBridgeCommandString];
//        
//    [self.manager addRemoteCommandID:@"test"
//                         description:@"testDescription"
//                         targetQueue:dispatch_get_main_queue()
//                       responseBlock:^(TEALRemoteCommandResponse *response) {
//                           
//                           responseBlockReceived = YES;
//                           
//                       } completion:^(BOOL success, NSError * _Nullable error) {
//                           
//                           completionError = error;
//                           completionSuccess = success;
//                           
//                           [expectation fulfill];
//                           
//                       }];
//    
//    
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
//    
//    XCTAssertTrue(!completionError, @"Unexpected completion error: %@", completionError);
//    
//    XCTAssertTrue(completionSuccess, @"Adding remote commmand was not successful.");
//    
//    
//    __block TEALRemoteCommandResponse *blockResponse = nil;
//    __block NSError *processcompletionError = nil;
//    __block BOOL isReady = NO;
//    
//    [self.manager processCommandString:commandString
//                             responseBlock:^(TEALRemoteCommandResponse *response) {
//                                 
//                                 blockResponse = response;
//                                 
//                             } completion:^(BOOL success, NSError * _Nullable error) {
//                                 
//                                 processcompletionError = error;
//                                 
//                                 isReady = YES;
//                                 
//                             }];
//    
//    [TEALTestHelper waitFor:&isReady timeout:2.0];
//    
//    XCTAssertTrue(isReady, @"Process command string never completed.");
//    
//    XCTAssertTrue(!processcompletionError, @"Unexpected completion error: %@", completionError);
//    
//    XCTAssertTrue(responseBlockReceived, @"Original response block never triggered.");
//    
//    XCTAssertTrue(blockResponse, @"No block response received.");
//}

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
