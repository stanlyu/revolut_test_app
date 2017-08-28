//
//  RTAExchangeOperationImpl.m
//  RevolutTestApp
//
//  Created by Stanislav on 08.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTAExchangeOperationImpl.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const expenseAccountKey = @"expenseAccount";
static NSString * const replenishmentAccountKey = @"replenishmentAccount";
static NSString * const amountChargedKey = @"amountCharged";
static NSString * const amountOfReplenishmentKey = @"amountOfReplenishment";

@implementation RTAExchangeOperationImpl

@synthesize expenseAccount = _expenseAccount, replenishmentAccount = _replenishmentAccount, amountCharged = _amountCharged, amountOfReplenishment = _amountOfReplenishment, delegate = _delegate;

#pragma mark - Initializers
- (instancetype)initWithExpenseAccount:(id<RTACurrencyAccount>)expenseAccount
                replenishmentAccount:(id<RTACurrencyAccount>)replenishmentAccount{
    self = [super init];
    if (self) {
        _expenseAccount = [expenseAccount copyWithZone:nil];
        _replenishmentAccount = [replenishmentAccount copyWithZone:nil];
        _amountCharged = DN(0);
        _amountOfReplenishment = DN(0);
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(serviceDidChangeCurrencyAccountsNotification:)
                                                   name:RTARevoluteServiceDidChangeCurrencyAccountsNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Public methods

- (NSDecimalNumber *)expenseReplenishmentRate {
    return [_expenseAccount.currency rateByCurrency:_replenishmentAccount.currency];
}

- (NSDecimalNumber *)replenishmentExpenseRate {
    return [_replenishmentAccount.currency rateByCurrency:_expenseAccount.currency];
}

- (void)setExpenseAccount:(id<RTACurrencyAccount>)expenseAccount {
    NSParameterAssert(expenseAccount);
    if (!expenseAccount) {
        return;
    }
    if (![_expenseAccount isEqual:expenseAccount]) {
        [self willChangeValueForKey:expenseAccountKey];
        _expenseAccount = expenseAccount;
        _amountCharged = [_amountOfReplenishment decimalNumberByDividingBy:[self expenseReplenishmentRate]];
        [self didChangeValueForKey:expenseAccountKey];
    }
}

- (void)setReplenishmentAccount:(id<RTACurrencyAccount>)replenishmentAccount {
    NSParameterAssert(replenishmentAccount);
    if (!replenishmentAccount) {
        return;
    }
    if (![_replenishmentAccount isEqual:replenishmentAccount]) {
        [self willChangeValueForKey:replenishmentAccountKey];
        _replenishmentAccount = replenishmentAccount;
        _amountOfReplenishment = [_amountCharged decimalNumberByMultiplyingBy:[self expenseReplenishmentRate]];
        [self didChangeValueForKey:replenishmentAccountKey];
    }
}

- (void)setAmountCharged:(NSDecimalNumber *)amountCharged {
    NSParameterAssert(amountCharged);
    NSParameterAssert([amountCharged isGreaterThanOrEqualTo:DN(0)]);
    if (!amountCharged) {
        return;
    }
    if (![_amountCharged isEqual:amountCharged]) {
        [self willChangeValueForKey:amountChargedKey];
        _amountCharged = amountCharged;
        [self didChangeValueForKey:amountChargedKey];
        [self willChangeValueForKey:amountOfReplenishmentKey];
        _amountOfReplenishment = [_amountCharged decimalNumberByMultiplyingBy:[self expenseReplenishmentRate]];
        [self didChangeValueForKey:amountOfReplenishmentKey];
        
    }
}

- (void)setAmountOfReplenishment:(NSDecimalNumber *)amountOfReplenishment {
    NSParameterAssert(amountOfReplenishment);
    NSParameterAssert([amountOfReplenishment isGreaterThanOrEqualTo:DN(0)]);
    if (!amountOfReplenishment) {
        return;
    }
    if (![_amountOfReplenishment isEqual:amountOfReplenishment]) {
        [self willChangeValueForKey:amountOfReplenishmentKey];
        _amountOfReplenishment = amountOfReplenishment;
        [self didChangeValueForKey:amountOfReplenishmentKey];
        [self willChangeValueForKey:amountChargedKey];
        _amountCharged = [_amountOfReplenishment decimalNumberByDividingBy:[self expenseReplenishmentRate]];
        [self didChangeValueForKey:amountChargedKey];

    }
}

- (nullable NSError *)validationError {
    if ([_expenseAccount.funds isLessThan:_amountCharged]) {
        return NSError.insufficientFundsError;
    }
    
    if ([_expenseAccount isEqual:_replenishmentAccount]) {
        return NSError.sameAccountsError;
    }
    
    if ([_amountCharged isEqualToDecimalNumber:DN(0)]) {
        return NSError.lackOfFundsError;
    }
    
    return nil;
}

- (BOOL)hasInsufficientFundsValidationError {
    return self.validationError.code == RTAInsufficientFundsErrorCode;
}

- (void)makeExchange {
    self.expenseAccount.funds = [self.expenseAccount.funds decimalNumberBySubtracting:self.amountCharged];
    self.replenishmentAccount.funds = [self.replenishmentAccount.funds decimalNumberByAdding:self.amountOfReplenishment];
    self.amountCharged = DN(0);
}

#pragma mark - Private methods

- (void)serviceDidChangeCurrencyAccountsNotification:(NSNotification *)notification {
    NSArray<id<RTACurrencyAccount>> *accounts = RTARevolutService.sharedInstance.currencyAccounts;
    BOOL __block isUpdated = NO;
    [accounts enumerateObjectsUsingBlock:^(id<RTACurrencyAccount>  _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account.currency.code isEqualToString:_expenseAccount.currency.code] && ![account isEqual:_expenseAccount]) {
            _expenseAccount = account;
            isUpdated = YES;
        }
        
        if ([account.currency.code isEqualToString:_replenishmentAccount.currency.code] && ![account isEqual:_replenishmentAccount]) {
            _replenishmentAccount = account;
            isUpdated = YES;
        }
    }];
    
    if (![accounts containsObject:self.expenseAccount]) {
        _expenseAccount = accounts[0];
    }
    
    if (![accounts containsObject:self.replenishmentAccount]) {
        _replenishmentAccount = accounts[1 % accounts.count];
    }
    
    if ([self isEditableAccount:self.expenseAccount]) {
        _amountOfReplenishment = [_amountCharged decimalNumberByMultiplyingBy:[self expenseReplenishmentRate]];
    } else if ([self isEditableAccount:self.replenishmentAccount]) {
        _amountCharged = [_amountOfReplenishment decimalNumberByDividingBy:[self expenseReplenishmentRate]];
    } else {
        _amountOfReplenishment = DN(0);
        _amountCharged = DN(0);
    }
    
    if (isUpdated && ![_expenseAccount isEqual:_replenishmentAccount] && [_delegate conformsToProtocol:@protocol(RTAExchangeOperationDelegate)]) {
        [_delegate exchangeOperationDidChange:self];
    }
}

- (BOOL)isEditableAccount:(id<RTACurrencyAccount>)account {
    if ([_delegate conformsToProtocol:@protocol(RTAExchangeOperationDelegate)]) {
        return [account isEqual:[_delegate currentEditableAccountForExchangeOperation:self]];
    }
    return NO;
}

@end

NS_ASSUME_NONNULL_END
