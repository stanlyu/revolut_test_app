//
//  NSDecimalNumber+Addition.m
//  RevolutTestApp
//
//  Created by Stanislav on 15.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "NSDecimalNumber+Addition.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDecimalNumber (Addition)

- (NSDecimalNumber *)absolute {
    return [self isGreaterThanOrEqualTo:DN(0)] ? self.copy : [self decimalNumberByMultiplyingBy:DN(-1)]; //DN(fabs(self.doubleValue));
}

- (NSDecimalNumber *)negative {
    return [self isLessThan:DN(0)] ? self.copy : [self decimalNumberByMultiplyingBy:DN(-1)];
}

@end

NS_ASSUME_NONNULL_END
