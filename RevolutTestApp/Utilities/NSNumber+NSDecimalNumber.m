//
//  NSNumber+NSDecimalNumber.m
//  RevolutTestApp
//
//  Created by Stanislav on 31.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "NSNumber+NSDecimalNumber.h"

@implementation NSNumber (NSDecimalNumber)

- (NSDecimalNumber *)decimalNumber {
    return [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
}

@end
