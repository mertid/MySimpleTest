//
//  TealiumLifecycleTests.m
//  TealiumTests
//
//  Created by Jason Koo on 10/19/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TEALLifecycle+PrivateTestHeader.h"
#import "TEALXMLParser.h"
#import <Tealium/TEALDataSourceConstants.h>

@interface TealiumLifecycleTests : XCTestCase

@property (nonatomic, strong) TEALLifecycle *lifecycle;

@end

@implementation TealiumLifecycleTests

- (void)setUp {
    [super setUp];
    self.lifecycle = [[TEALLifecycle alloc] initWithInstanceID:@"testInstance"];
    [self.lifecycle reset];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.lifecycle = nil;
    [super tearDown];
}


#pragma mark - TESTS

- (void) testEvents {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"parser test"];
    
    __block NSDictionary* aLifecycleEvent = nil;;
    
    TEALXMLParser *delegate = [[TEALXMLParser alloc] initWithCompletion:^(NSDate *eventDate, NSDictionary *lifecycleEvent, BOOL finished) {
        aLifecycleEvent = lifecycleEvent;
        
        __block typeof(self) __weak weakSelf = self;

        NSString *eventName = aLifecycleEvent[TEALDataSourceKey_LifecycleType];
        
        
        
        
        [self.lifecycle incrementEventWithName:eventName
                                          date:eventDate
                                    completion:^(NSDictionary *lifecycleData, NSError *error) {
                                       
                                        
                                    }];
        
        
        if (finished == YES){
            [expectation fulfill];
        }
    }];
    



    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"lifecycle_events" ofType:@"xml"];
    NSInputStream *stream =[[NSInputStream alloc] initWithFileAtPath:path];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:stream];
    [parser setDelegate:delegate];
    [parser parse];
    
    // TODO: increase wait time, almost 1 second to just iterate through file
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    
    
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
