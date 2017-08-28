//
//  NSDecimalNumber+Comparison.h
//  RevolutTestApp
//
//  Created by Stanislav on 31.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Comparison)

- (BOOL)isLessThan:(NSDecimalNumber *)decimalNumber;
- (BOOL)isLessThanOrEqualTo:(NSDecimalNumber *)decimalNumber;
- (BOOL)isGreaterThan:(NSDecimalNumber *)decimalNumber;
- (BOOL)isGreaterThanOrEqualTo:(NSDecimalNumber *)decimalNumber;
- (BOOL)isEqualToDecimalNumber:(NSDecimalNumber *)decimalNumber;
- (BOOL)isNotANumber;

@end
