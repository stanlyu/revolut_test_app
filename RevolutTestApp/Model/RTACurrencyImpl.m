//
//  RTACurrencyImpl.m
//  RevolutTestApp
//
//  Created by Stanislav on 28.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyImpl.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const kEUR = @"EUR";
NSString * const kGBP = @"GBP";
NSString * const kUSD = @"USD";

NSString * const kEURSign = @"€";
NSString * const kGBPSign = @"£";
NSString * const kUSDSign = @"$";

static NSString * const currencyKey = @"_currency";
static NSString * const rateKey = @"_rate";

@interface RTACurrencyImpl ()

@property (class, readonly) NSDictionary<NSString *, NSString *> *codeSignDictionary;

@end

@implementation RTACurrencyImpl

@synthesize code = _code, rate = _rate;

#pragma mark - Initializers
- (instancetype)initWithCode:(NSString *)code rate:(NSNumber *)rate {
    NSParameterAssert(code);
    NSParameterAssert(rate);
    if (!code || !rate) {
        return nil;
    }
    self = [super init];
    if (self) {
        _code = code.copy;
        _rate = rate.copy;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    return [self initWithCode:dictionary[currencyKey] rate:dictionary[rateKey].decimalNumber];
}

#pragma mark - Public methods
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[RTACurrencyImpl class]]) {
        return NO;
    }
    
    return [self isEqualToCurrency:(RTACurrencyImpl *)object];
}

-(NSUInteger)hash {
    return _code.hash ^ _rate.hash ^ self.sign.hash;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    return [[RTACurrencyImpl alloc] initWithCode:_code rate:_rate];
}

- (NSDecimalNumber *)rateByCurrency:(id<RTACurrency>)anotherCurrency {
    return [anotherCurrency.rate decimalNumberByDividingBy:_rate];
}

- (NSString *)sign {
    return RTACurrencyImpl.codeSignDictionary[_code] != nil ? RTACurrencyImpl.codeSignDictionary[_code] : @"";
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{ code: \"%@\", rate: %@ }", _code, _rate];
}

#pragma mark - Private methods
- (BOOL)isEqualToCurrency:(RTACurrencyImpl *)currency {
    if (!currency) {
        return NO;
    }
    BOOL codesEqual = [_code isEqualToString:currency.code];
    BOOL ratesEqual = [_rate isEqualToNumber:currency.rate];
    return codesEqual && ratesEqual;
}

+ (NSDictionary<NSString *, NSString *> *)codeSignDictionary {
    return @{
             kEUR : kEURSign,
             kGBP : kGBPSign,
             kUSD : kUSDSign
             };
}

@end

NS_ASSUME_NONNULL_END
