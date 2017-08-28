//
//  RTACurrencyAccountImpl.m
//  RevolutTestApp
//
//  Created by Stanislav on 31.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyAccountImpl.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RTACurrencyAccountImpl

@synthesize currency = _currency, funds = _funds;

#pragma mark - Initializers
- (instancetype)initWithCurrency:(id<RTACurrency>)currency funds:(NSDecimalNumber *)funds {
    self = [super init];
    if (self) {
        _currency = [currency copyWithZone:nil];
        _funds = funds.copy;
    }
    return self;
}

#pragma mark - Public methods
- (instancetype)copyWithZone:(nullable NSZone *)zone {
    return [[RTACurrencyAccountImpl alloc] initWithCurrency:_currency funds:_funds];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[RTACurrencyAccountImpl class]]) {
        return NO;
    }
    
    return [self isEqualToCurrencyAccount:(RTACurrencyAccountImpl *)object];
}

- (NSUInteger)hash {
    return _currency.hash ^ _funds.hash;
}

#pragma mark - Private methods
- (BOOL)isEqualToCurrencyAccount:(RTACurrencyAccountImpl *)currencyAccount {
    if (!currencyAccount) {
        return NO;
    }
    BOOL currenciesEqual = [_currency isEqual:currencyAccount.currency];
    BOOL fundsEqual = [_funds isEqualToNumber:currencyAccount.funds];
    return currenciesEqual && fundsEqual;
}

@end

NS_ASSUME_NONNULL_END
