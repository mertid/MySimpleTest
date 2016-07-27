//
//  TEALDatasourcesTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TEALDataSources.h"
#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALDeviceDataSources.h"

@interface TEALDatasourcesTests : XCTestCase

@property (nonatomic, strong) TEALDataSources *dataSources;
@property __block Tealium *library;

@end

@implementation TEALDatasourcesTests

- (void)setUp {
    [super setUp];
    self.dataSources = [[TEALDataSources alloc] initWithInstanceID:@"testInstance"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.dataSources = nil;
    [super tearDown];
}

#pragma mark - PRIMARY TESTS

- (void) testUUID {
    
    __block NSString *uuid;
    
    [self measureBlock:^{
        
         uuid = [self.dataSources uuid];
        
    }];
    
    XCTAssertTrue(uuid, @"UUID was not created.");
    XCTAssertTrue([self acceptableUUID:uuid], @"Incorrect UUID format found: %@.", uuid);
}

- (void) testAddAndPurgePersistentDataSources {
    
    NSDictionary *dataSources = @{
                                  @"testKey":@"testValue"
                                  };

    [self.dataSources addPersistentDataSources:dataSources];
    
    NSDictionary *retrieved = [self.dataSources persistentDataSources];
    
    // Checking just for the keys added
    for (NSString *key in [dataSources allKeys]) {
     
        NSString *dataSourceValue = dataSources[key];
        NSString *retrievedValue = retrieved[key];
        
        XCTAssertTrue([dataSourceValue isEqualToString:retrievedValue], @"Mismatch for key: %@, retrieved value: %@ expected value: %@", key, retrievedValue, dataSourceValue);
        
    }
    
    [self.dataSources purgePersistentDataSources];
    
    NSDictionary *purgedDataSources = [self.dataSources persistentDataSources];
    
    // UUID is always regenerated
    XCTAssertTrue([[purgedDataSources allKeys] count] == 1, @"Non empy persistent data found: %@", purgedDataSources);
    XCTAssertTrue(purgedDataSources[@"uuid"], @"Unexpected persistent data contente: %@", purgedDataSources);

}

- (void) testUniversalDataSourcesKeyExist{
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    
    NSDictionary *allSampleData = [TEALTestHelper dictionaryFromJSONFile:@"tealium_track_data"];
    NSArray *sampleData = allSampleData[@"events"];
    
    
    NSMutableDictionary *inputData = [[NSMutableDictionary alloc]init];
    
    [inputData setValue:@"test" forKey:@"event_name"];
    
    //call track event
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testtrackeventuniversaldatasources"];
    
    for (int i = 0; i < sampleData.count; i++) {
        
        NSDictionary *testData = sampleData[i][@"input_data"][@"test_data"];
        __block NSDictionary *expectedOutput = sampleData[i][@"expected_data"];
        
        [inputData setValue:testData forKey:@"test_data"];
        
        __block int interation = i;
        __block int lastIndex = sampleData.count -1;
       
        [self.library trackDispatchOfType:TEALDispatchTypeEvent title:@"test" dataSources:inputData
                               completion:^(TEALDispatchStatus status,
                                            TEALDispatch * _Nonnull dispatch,
                                            NSError * _Nullable error) {
            
                                   NSError *dictionaryError = nil;
                                  
                                   BOOL doesContain = [TEALTestHelper doesDictionary:[dispatch payload] containDictionaryKeys:expectedOutput error:&dictionaryError];
                                   
                                   NSString *function = @"testTrackEventUniversalDataSources";
            
                                   NSString *inputDebug = [NSString stringWithFormat:@"Input data : %@ ", inputData];
                                   NSString *dispatchDebug = [NSString stringWithFormat:@"Return Dispatch : %@ ", [dispatch payload]];
                                   NSString *outputDebug = [NSString stringWithFormat:@"Expected output : %@ ", expectedOutput];
            
                                   XCTAssertTrue(doesContain, @" %@, %@,  %@, %@", inputDebug, dispatchDebug, outputDebug, function);
            
            if (interation == lastIndex){
                
                [expectation fulfill];
                
            }
        }];
    }
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

-(void) testRandomValue{
    
    //verify not repeated values
    NSMutableArray *randomArray = [NSMutableArray new];

    for (int i = 0; i < 1000; i++){
        NSString *randomNumber = [TEALDeviceDataSources randomNumber];
        
        if(![randomArray containsObject:randomNumber]){
            [randomArray addObject:randomNumber];
        
        }else{
            XCTAssert(@"Randomness is not occurring %@");
        
        }
        
    }

}

-(void) testSessionId {
    
    NSString *function = @"testSessionID";
//    
//    for (int unixTimeStamp = -10000; unixTimeStamp < 10000; unixTimeStamp+=100){
//
//        int convertTimeStamp = unixTimeStamp *1000;
//        NSString *testTimeStampString = [NSString stringWithFormat:@"%d", convertTimeStamp];
//        NSDate *testdate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
//        NSString *sessionIdString = [TEALDataSources resetSessionID:testdate];
//        
//        XCTAssertEqual(sessionIdString, testTimeStampString, @"%@", function);
//        
//        }
    
    int testDateUnix = -500000;    // 7/27/1955 14:51:34
    
    NSString *dateValue = @"1969.12.31 AD at 23:51:40 UTC";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *formatString = @"yyyy.MM.dd G 'at' HH:mm:ss zzz";
    [formatter setDateFormat:formatString];
    NSDate *date = [formatter dateFromString:dateValue];
    
    NSString *sessionId = [TEALDataSources resetSessionID:date];
    NSString *testDateUnixString = [NSString stringWithFormat:@"%d", testDateUnix];
    
    XCTAssertEqual(sessionId, testDateUnixString,  @"%@ SessionID %@  Hardcoded TimeStamp %@", function, sessionId, testDateUnixString);
}

-(void) testDictionaryContainsKeys{
  
    NSError *error = nil;
    
//  String as Keys
    NSDictionary *dict1 = @{
                            @"Mercedes-Benz SLK250" : @13,
                            @"Mercedes-Benz E350" : @22,
                            @"BMW M3 Coupe" : @19
                            };

    NSDictionary *dict2 = @{
                            @"Mercedes-Benz SLK250" : @13,
                            @"BMW M3 Coupe" : @19
                            };

    XCTAssertTrue([TEALTestHelper doesDictionary:dict1 containDictionaryKeys:dict2 error:&error], @"%@" , error);

// Numbers as Keys
    NSDictionary *dict3 = @{
                            @13 : @13,
                            @"BMW X6" : @16,
                            };
    
    
    NSDictionary *dict4 = @{
                            @13 : @13,
                            };
    
    XCTAssertTrue([TEALTestHelper doesDictionary:dict3 containDictionaryKeys:dict4 error:&error], @"%@", error);

// Compare a Number to a String - Should Evaluate to false
    NSDictionary *dict5 = @{
                            @13 : @13,
                            @"BMW X6" : @16,
                            };
    
    
    NSDictionary *dict6 = @{
                            @"13" : @13,
                            };
    
    XCTAssertFalse([TEALTestHelper doesDictionary:dict5 containDictionaryKeys:dict6 error:&error], @"%@", error);
    
// Compare a String to a Number - Should Evaluate to false
    NSDictionary *dict7 = @{
                            @"13" : @13,
                            };
    
    NSDictionary *dict8 = @{
                            @13: @13,
                            @"BMW X6" : @16,
                            };
    
    XCTAssertFalse([TEALTestHelper doesDictionary:dict7 containDictionaryKeys:dict8 error:&error], @"%@", error);

}

-(void) testDictionaryContainsDictionary {
    
    NSError *error = nil;

// String as Values
    NSDictionary *dict1 = @{
                            @"Mercedes-Benz SLK250" : @"foo",
                            @"Mercedes-Benz E350" : @"bar",
                            @"BMW M3 Coupe" : @16
                            };
    
    NSDictionary *dict2 = @{
                            @"Mercedes-Benz SLK250" : @"foo",
                            };
    
    XCTAssertTrue([TEALTestHelper doesDictionary:dict1 containsDictionary:dict2 error:&error], @"%@", error);
    
// Compare a Number to a String --should evaluate to false
    NSDictionary *dict3 = @{
                            @13 : @13,
                            @"BMW X6" : @16
                            };
    
    NSDictionary *dict4 = @{
                            @13 : @"13"
                            };
    
    XCTAssertFalse([TEALTestHelper doesDictionary:dict3 containsDictionary:dict4 error:&error], @"%@", error);

// Compare a String to number --should evaluate to false
    NSDictionary *dict5 = @{
                            @13 : @"13",
                            };
    
    NSDictionary *dict6 = @{
                            @13 : @13
                            };
    
    XCTAssertFalse([TEALTestHelper doesDictionary:dict5 containsDictionary:dict6 error:&error], @"%@", error);
    
// NSArray of strings value check
    NSArray *testArray = @[@"foo", @"bar"];
    
    NSDictionary *dict7 = @{
                            @13 : testArray
                            };
    
    NSDictionary *dict8 = @{
                            @13 : testArray
                            };

    XCTAssertTrue([TEALTestHelper doesDictionary:dict7 containsDictionary:dict8 error:&error], @"%@", error);

// NSArray of numbers value check
    NSArray *testArray2 = @[@10, @11];
    
    NSDictionary *dict9 = @{
                            @13 : testArray2,
                            };
    
    NSDictionary *dict10 = @{
                             @13 : testArray2
                             };
    
    XCTAssertTrue([TEALTestHelper doesDictionary:dict9 containsDictionary:dict10 error:&error], @"%@", error);
    
// Compare Number and String Values in an array
    NSNumber *number1 = @45;
    NSNumber *number2 = @40;
    NSString *testString = @"bar";
   
    NSArray *testArray3 = @[number1, number2, testString];
    
    NSDictionary *dict13 = @{
                            @"Foo": testArray3,
                            };
    
    NSDictionary *dict14 = @{
                             @"Foo": testArray3,
                            };
    
    XCTAssertTrue([TEALTestHelper doesDictionary:dict13 containsDictionary:dict14 error:&error], @"%@", error);
    
}


#pragma mark - HELPERS

- (BOOL) acceptableUUID:(NSString *)uuid {
    
    NSError *regexError = nil;
    
    NSString *scriptContentsPattern = @"^[A-F0-9]{8}\\-([A-F0-9]{4}\\-){3}[A-F0-9]{12}$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:scriptContentsPattern
                                                                           options:0
                                                                             error:&regexError];
    if (!regex) {
        return NO;
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:uuid
                                                        options:0
                                                          range:NSMakeRange(0, [uuid length])];
    
//    NSLog(@"%s Number of matches: %lu", __FUNCTION__, (unsigned long)numberOfMatches);
    
    if (numberOfMatches == 1) {
        return YES;
    }
    
    return NO;
}

@end
