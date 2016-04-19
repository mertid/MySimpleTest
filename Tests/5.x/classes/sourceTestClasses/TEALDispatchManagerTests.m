//
//  TEALDispatchManagerTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/27/16.
//
//

#import <XCTest/XCTest.h>
#import "TEALDispatchManager.h"
#import "TEALDispatch.h"

@interface TEALDispatchManagerTests : XCTestCase<TEALDispatchManagerDelegate>

@property TEALDispatchManager *manager;
@property NSUInteger batchSizeToTest;
@property NSUInteger queueCapacityToTest;
@property NSUInteger sampleQueueSizeToTest;
@property BOOL shouldDestroy;
@property BOOL shouldDispatch;
@property BOOL shouldPurge;
@property BOOL shouldQueue;
@property TEALDispatchStatus sentDispatchStatus;

@property int sendCount;
@property int queueCount;

@end

@implementation TEALDispatchManagerTests

- (void)setUp {
    [super setUp];
    
    self.manager = [[TEALDispatchManager alloc] initWithInstanceID:@"dispatchManagerTests"
                                                          delegate:self];
    self.batchSizeToTest = 0;
    self.queueCapacityToTest = 0;
    self.shouldDestroy = NO;
    self.shouldDispatch = YES;
    self.shouldPurge = NO;
    self.shouldQueue = NO;
    self.sendCount = 0;
    self.queueCount = 0;
    self.sentDispatchStatus = TEALDispatchStatusUnknown;
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    
    self.manager = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.tealium.dispatch_queue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - TESTS

- (void) testDispatchManagerAddSingleDispatch {
    
    self.shouldDispatch = YES;
    self.sentDispatchStatus = TEALDispatchStatusSent;
    
    TEALDispatch *dispatch = [[TEALDispatch alloc] init];
    
    XCTAssertTrue(dispatch, @"Test dispatch did not init.");

    XCTAssertTrue(self.manager, @"Test dispatchManger not available.");

    XCTestExpectation *e = [self expectationWithDescription:@"singleDispatch"];
    
    __block TEALDispatchStatus addedStatus = TEALDispatchStatusUnknown;
    __block TEALDispatch *addedDispatch = nil;
    __block NSError *addedError = nil;
    
    [self.manager addDispatch:dispatch
              completionBlock:^(TEALDispatchStatus status,
                                TEALDispatch * _Nonnull dispatch,
                                NSError * _Nullable error) {
                  
                  addedStatus = status;
                  addedDispatch = dispatch;
                  addedError = error;
                  
                  [e fulfill];
                  
              }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(addedStatus == self.sentDispatchStatus, @"Incorrect TEALDispatchStatus returned: %lu", (unsigned long)addedStatus);
    
    XCTAssertTrue(addedDispatch, @"Missing dispatch in completion.");
    
    XCTAssertTrue(!addedError, @"Unexpected error: %@", addedError);
    
}

- (void) testUpdateQueueCapacityWithNegativeNumber {
    
    [self.manager updateQueuedCapacity:-1];
    
        NSLog(@"%s queue capacity: %lu", __FUNCTION__, (unsigned long)self.manager.queueCapacity);
//    XCTAssertTrue(self.manager.queueCapacity 
}

- (void) testUpdateQueueCapacityWithZero {
    
    [self.manager updateQueuedCapacity:0];
    
    XCTAssertTrue(self.manager.queueCapacity == 0);
}

- (void) testUpdateQueueCapacityWithExtrememlyLargeNumber {
    
    [self.manager updateQueuedCapacity:NSIntegerMax];
    
    XCTAssertTrue(self.manager.queueCapacity == NSIntegerMax / 2);
}


- (void) testAutoAdjustCapacitySizeWithNegativeNumber {
    
    self.sampleQueueSizeToTest = 20;
    self.queueCapacityToTest = -1;
    
    NSMutableArray *sampleQueue = [self sampleDispatchQueue];
    
    [self.manager updateQueuedCapacity:self.queueCapacityToTest];
    
    [self.manager autoAdjustQueueSize:sampleQueue];
    
    XCTAssertTrue(sampleQueue.count <= self.queueCapacityToTest, @"End queued dispatches was %lu - not the expected %lu", sampleQueue.count, self.queueCapacityToTest);
    
}

- (void) testAutoAdjustQueueSize {

    self.sampleQueueSizeToTest = 20;
    self.queueCapacityToTest = 10;

    NSMutableArray *sampleQueue = [self sampleDispatchQueue];
    
    [self.manager updateQueuedCapacity:self.queueCapacityToTest];
    
    [self.manager autoAdjustQueueSize:sampleQueue];
    
    XCTAssertTrue(sampleQueue.count <= self.queueCapacityToTest, @"End queued dispatches was %lu - not the expected %lu", sampleQueue.count, self.queueCapacityToTest);
    
}

- (void) testAutoAdjustQueueSizeWithExtremelyLargeCapacity {
    
    self.sampleQueueSizeToTest = 20;
    self.queueCapacityToTest = NSUIntegerMax;
    
    NSMutableArray *sampleQueue = [self sampleDispatchQueue];
    
    [self.manager updateQueuedCapacity:self.queueCapacityToTest];
    
    [self.manager autoAdjustQueueSize:sampleQueue];
    
    XCTAssertTrue(sampleQueue.count <= self.queueCapacityToTest, @"End queued dispatches was %lu - not the expected %lu", sampleQueue.count, self.queueCapacityToTest);
    
}

- (void) testAutoAdjustQueueSizeWithDefaultQueue {
    
    self.sampleQueueSizeToTest = 100;
    self.queueCapacityToTest = 10;
    
    NSMutableArray *sampleQueue = [self sampleDispatchQueue];
    
    [self.manager updateQueuedCapacity:self.queueCapacityToTest];
    
    [self.manager autoAdjustQueueSize:sampleQueue];
    
    XCTAssertTrue(sampleQueue.count <= self.queueCapacityToTest, @"End queued dispatches was %lu - not the expected %lu", sampleQueue.count, self.queueCapacityToTest);
    
}

- (NSMutableArray *) sampleDispatchQueue {
    
    NSMutableArray *samples = [NSMutableArray array];
    
    NSUInteger size = self.sampleQueueSizeToTest;
    
    for (NSUInteger i; i < size; i++) {
        
        TEALDispatch *dispatch = [[TEALDispatch alloc] init];
        
        [samples addObject:dispatch];
        
    }
    
    return samples;
    
}

- (void) testLoadEmptyDispatches {
    
    NSMutableArray *dispatches = [self.manager savedDispatches];
    
    XCTAssertTrue(dispatches.count == 0);
    
}

- (void) testSaveAndLoadDispatches {
    
    self.sampleQueueSizeToTest = 10;
    
    NSMutableArray *sampleQueue = [self sampleDispatchQueue];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"saveDispatches"];
    
    [self.manager saveDispatches:sampleQueue
                      completion:^(BOOL success, NSError *error){
                      
                          [expectation fulfill];
                          
                      }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    NSArray *savedDispatches = [self.manager savedDispatches];
    
    XCTAssertTrue(savedDispatches.count == sampleQueue.count);
    
    // TODO: expand test to check values of objects between arrays.  The equalToArray
    // method falsely returns false.
    
}
//#pragma mark - DISPATCH MANAGER CONFIGURATION
//
//- (NSUInteger) dispatchBatchSize {
//    
//    return self.batchSizeToTest;
//    
//}
//
//- (NSUInteger) dispatchQueueCapacity {
//    
//    return self.queueCapacityToTest;
//    
//}

#pragma mark - DISPATCH MANAGER DELEGATE

- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock{
    
    
    dispatch.dispatchServiceName = @"testDispatchService";
    
    if (completionBlock){
        completionBlock(self.sentDispatchStatus, dispatch, nil);
    }
}

- (BOOL) dispatchManagerShouldDispatch:(NSError * __autoreleasing *)error {
    
    return self.shouldDispatch;
    
}

- (BOOL) dispatchManagerShouldDestroyDispatch:(TEALDispatch *)dispatch {

    return self.shouldDestroy;
    
}


- (BOOL) dispatchManagerShouldQueueDispatch:(TEALDispatch *)dispatch {

    return self.shouldQueue;

}

- (BOOL) dispatchManagerShouldPurgeDispatch:(TEALDispatch *)dispatch {
    
    return self.shouldPurge;
    
}

- (void) dispatchManagerdDidPurgeDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s dispatch:%@", __FUNCTION__, dispatch);
    
}

- (void) dispatchManagerdDidRunDispatchQueueWithCount:(NSUInteger)count {
    
        NSLog(@"%s count: %lu", __FUNCTION__, count);
    
}

- (void) dispatchManagerDidSendDispatch:(TEALDispatch *)dispatch{
    
    self.sendCount++;
}

- (void) dispatchManagerDidEnqueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount++;
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
