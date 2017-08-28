//
//  NSDecimalNumber+Comparison.m
//  RevolutTestApp
//
//  Created by Stanislav on 31.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "NSDecimalNumber+Comparison.h"

@implementation NSDecimalNumber (Comparison)

- (BOOL)isLessThan:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] == NSOrderedAscending;
}

- (BOOL)isLessThanOrEqualTo:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] != NSOrderedDescending;
}

- (BOOL)isGreaterThan:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] == NSOrderedDescending;
}

- (BOOL)isGreaterThanOrEqualTo:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] != NSOrderedAscending;
}

- (BOOL)isEqualToDecimalNumber:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] == NSOrderedSame;
}

- (BOOL)isNotANumber {
    return [self compare:NSDecimalNumber.notANumber] == NSOrderedSame;
}

@end
