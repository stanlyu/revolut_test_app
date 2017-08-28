//
//  RTAExchangeOperation.h
//  RevolutTestApp
//
//  Created by Stanislav on 08.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTACurrencyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RTAExchangeOperation;

@protocol RTAExchangeOperationDelegate <NSObject>

- (void)exchangeOperationDidChange:(id<RTAExchangeOperation>)operation;
- (nullable id<RTACurrencyAccount>)currentEditableAccountForExchangeOperation:(id<RTAExchangeOperation>)operation;

@end

@protocol RTAExchangeOperation <NSObject>

@property (copy) id<RTACurrencyAccount> expenseAccount;
@property (copy) id<RTACurrencyAccount> replenishmentAccount;
@property (copy) NSDecimalNumber *amountCharged;
@property (copy) NSDecimalNumber *amountOfReplenishment;
@property (copy, readonly) NSDecimalNumber *expenseReplenishmentRate;
@property (copy, readonly) NSDecimalNumber *replenishmentExpenseRate;
@property (weak) id<RTAExchangeOperationDelegate> delegate;
@property (readonly, nullable) NSError *validationError;
@property (assign, readonly) BOOL hasInsufficientFundsValidationError;

- (void)makeExchange;

@end

NS_ASSUME_NONNULL_END
