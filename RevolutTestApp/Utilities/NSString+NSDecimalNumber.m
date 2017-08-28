//
//  NSString+NSDecimalNumber.m
//  RevolutTestApp
//
//  Created by Stanislav on 18.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "NSString+NSDecimalNumber.h"

@implementation NSString (NSDecimalNumber)

- (NSDecimalNumber *)decimalNumber {
    return [NSDecimalNumber decimalNumberWithString:self];
}

@end
