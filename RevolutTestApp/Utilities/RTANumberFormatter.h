//
//  RTANumberFormatter.h
//  RevolutTestApp
//
//  Created by Stanislav on 15.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTANumberFormatter : NSObject

@property (nonatomic, class, readonly) RTANumberFormatter *expenseAmountFormatter;
@property (nonatomic, class, readonly) RTANumberFormatter *replenishmentAmountFormatter;
@property (nonatomic, class, readonly) RTANumberFormatter *rateFormatter;

- (nullable NSString *)stringFromNumber:(NSNumber *)number;

@end

NS_ASSUME_NONNULL_END
