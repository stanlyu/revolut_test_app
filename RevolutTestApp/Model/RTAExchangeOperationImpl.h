//
//  RTAExchangeOperationImpl.h
//  RevolutTestApp
//
//  Created by Stanislav on 08.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTAExchangeOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTAExchangeOperationImpl : NSObject <RTAExchangeOperation>

- (instancetype)initWithExpenseAccount:(id<RTACurrencyAccount>)expenseAccount
                replenishmentAccount:(id<RTACurrencyAccount>)replenishmentAccount NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
