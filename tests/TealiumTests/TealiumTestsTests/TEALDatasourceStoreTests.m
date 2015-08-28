//
//  TEALDatasourceStoreTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/6/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Tealium/TEALDatasourceStore.h>

@interface TEALDatasourceStoreTests : XCTestCase

@property (nonatomic, strong) TEALDataSourceStore *store;

@end

@implementation TEALDatasourceStoreTests

- (void)setUp {
    [super setUp];
//    self.store = [[TEALDatasourceStore alloc] initWithInstanceID:@"tealiummobile_test_dev"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.store = nil;
    [super tearDown];
    
}



@end
