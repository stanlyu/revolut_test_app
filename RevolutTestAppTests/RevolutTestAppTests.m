//
//  RevolutTestAppTests.m
//  RevolutTestAppTests
//
//  Created by Stanislav on 31.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RTACurrencyAccountImpl.h"
#import "RTACurrencyImpl.h"
#import "RTARevolutService.h"
#import "NSNumber+NSDecimalNumber.h"
#import "NSDecimalNumber+Comparison.h"
#import "RTAExchangeOperationImpl.h"

@interface RevolutTestAppTests : XCTestCase

@property RTACurrencyAccountImpl *RUBAccount;
@property RTACurrencyAccountImpl *USDAccount;

@end

@implementation RevolutTestAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    RTACurrencyImpl *rubCur = [[RTACurrencyImpl alloc] initWithCode:@"RUB" rate:@(69.1235).decimalNumber];
    _RUBAccount = [[RTACurrencyAccountImpl alloc] initWithCurrency:rubCur funds:@(300.0).decimalNumber];
    
    RTACurrencyImpl *usdCur = [[RTACurrencyImpl alloc] initWithCode:@"USD" rate:@(1.1825).decimalNumber];
    _USDAccount = [[RTACurrencyAccountImpl alloc] initWithCurrency:usdCur funds:@(5.0).decimalNumber];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testCalculationOfExchangesBeetweenCurrencyAccounts {
//    NSError *error;
//    NSDecimalNumber *result = [RTARevolutService.sharedInstance calculateExchangeOfCurrencyAmount:@(200.0).decimalNumber fromSourceCurrencyAccount:self.RUBAccount toTargetCurrencyAccount:self.USDAccount error:&error];
    RTAExchangeOperationImpl *exOp = [[RTAExchangeOperationImpl alloc] initWithExpenseAccount:self.RUBAccount replenishmentAccount:self.USDAccount];
    exOp.amountCharged = @(200).decimalNumber;
    XCTAssert([exOp.amountOfReplenishment isEqualToDecimalNumber:@(3.42).decimalNumber], @"Incorrect calculation of exchange of 200.0 RUB to USD (%@)", exOp.amountOfReplenishment);
}

@end
