//
//  RTANumberFormatter.m
//  RevolutTestApp
//
//  Created by Stanislav on 15.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTANumberFormatter.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTANumberFormatter ()

@property NSNumberFormatter *wrappedFormatter;

@end

@implementation RTANumberFormatter

+ (RTANumberFormatter *)expenseAmountFormatter {
    static RTANumberFormatter *expenseAmountFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expenseAmountFormatter = [RTANumberFormatter new];
        expenseAmountFormatter.wrappedFormatter = [self createWrappedFormatter];
        expenseAmountFormatter.wrappedFormatter.positivePrefix = @"-";
    });
    
    return expenseAmountFormatter;
}

+ (RTANumberFormatter *)replenishmentAmountFormatter {
    static RTANumberFormatter *expenseAmountFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expenseAmountFormatter = [RTANumberFormatter new];
        expenseAmountFormatter.wrappedFormatter = [self createWrappedFormatter];
        expenseAmountFormatter.wrappedFormatter.positivePrefix = @"+";
        expenseAmountFormatter.wrappedFormatter.negativePrefix = @"+";
    });
    
    return expenseAmountFormatter;
}

+ (RTANumberFormatter *)rateFormatter {
    static RTANumberFormatter *rateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rateFormatter = [RTANumberFormatter new];
        rateFormatter.wrappedFormatter = [self createWrappedFormatter];
    });
    
    return rateFormatter;
}

- (nullable NSString *)stringFromNumber:(NSNumber *)number {
    return [self.wrappedFormatter stringFromNumber:number];
}

#pragma mark - Private methods

+ (NSNumberFormatter *)createWrappedFormatter {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 0;
    formatter.minimumIntegerDigits = 1;
    formatter.roundingMode = NSNumberFormatterRoundDown;
    return formatter;
}

@end

NS_ASSUME_NONNULL_END
