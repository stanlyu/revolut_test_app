//
//  RTANetworkDataTransport+Testing.m
//  RevolutTestApp
//
//  Created by Stanislav on 19.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTANetworkDataTransport+Testing.h"

#if defined(RTANDT_LOAD_CURRENCIES_INSTANTLY) || \
defined(RTANDT_LOAD_CURRENCIES_FOR_SOME_TIME) || \
defined(RTANDT_LOAD_CURRENCIES_WITH_ERROR_INSTANTLY) || \
defined(RTANDT_LOAD_CURRENCIES_WITH_ERROR_FOR_SOME_TIME) || \
defined(RTANDT_LOAD_CURRENCIES_FIRST_WITH_ERROR_THEN_SUCCESSFULLY) || \
defined(RTANDT_LOAD_CURRENCIES_RANDOMLY)

#import <JRSwizzle/JRSwizzle.h>
#import "RTACurrencyImpl.h"

@implementation RTANetworkDataTransport (Testing)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jr_swizzleMethod:@selector(loadCurrenciesWithCompletionHandler:)
                    withMethod:@selector(rta_loadCurrenciesWithCompletionHandler:)
                         error:nil];
    });
}

- (void)rta_loadCurrenciesWithCompletionHandler:(void (^)(NSArray<id<RTACurrency>> * _Nullable,
                                                          NSError * _Nullable))completionHandler {
#ifdef RTANDT_LOAD_CURRENCIES_INSTANTLY
    NSArray<id<RTACurrency>> *currencies = [self generateCurrencies];
    completionHandler(currencies, nil);
#elif defined(RTANDT_LOAD_CURRENCIES_FOR_SOME_TIME)
    NSArray<id<RTACurrency>> *currencies = [self generateCurrencies];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(currencies, nil);
    });
#elif defined(RTANDT_LOAD_CURRENCIES_WITH_ERROR_INSTANTLY)
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
    completionHandler(nil, error);
#elif defined(RTANDT_LOAD_CURRENCIES_WITH_ERROR_FOR_SOME_TIME)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
        completionHandler(nil, error);
    });
#elif defined(RTANDT_LOAD_CURRENCIES_FIRST_WITH_ERROR_THEN_SUCCESSFULLY) \
|| defined(RTA_REVOLUT_SERVICE_LOAD_ACCOUNTS_OR_WITH_ERROR_OR_SUCCESSFULLY)
#ifdef RTANDT_LOAD_CURRENCIES_RANDOMLY
    static BOOL hasError = NO;
    hasError = (BOOL)arc4random_uniform(2);
#else
    static BOOL hasError = YES;
#endif // RTANDT_LOAD_CURRENCIES_RANDOMLY
    if (hasError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
            completionHandler(nil, error);
        });
        hasError = NO;
    } else {
        NSArray<id<RTACurrency>> *currencies = [self generateCurrencies];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionHandler(currencies, nil);
        });
    }
#endif // RTANDT_LOAD_CURRENCIES_FIRST_WITH_ERROR_THEN_SUCCESSFULLY || RTA_REVOLUT_SERVICE_LOAD_ACCOUNTS_OR_WITH_ERROR_OR_SUCCESSFULLY
}

- (NSArray<id<RTACurrency>> *)generateCurrencies {
    NSArray<NSDecimalNumber *> *usdRates = @[DN(1.1997), DN(1.1947), DN(1.1897)];
    NSArray<NSDecimalNumber *> *gbpRates = @[DN(0.90775), DN(0.9178), DN(0.9)];
    NSInteger index = (NSInteger)arc4random_uniform(3);
    id<RTACurrency> usd = [[RTACurrencyImpl alloc] initWithCode:kUSD rate:usdRates[index]];
    index = (NSInteger)arc4random_uniform(3);
    id<RTACurrency> gbp = [[RTACurrencyImpl alloc] initWithCode:kGBP rate:gbpRates[index]];
    id<RTACurrency> eur = [[RTACurrencyImpl alloc] initWithCode:kEUR rate:DN(1.0)];
    return @[usd, gbp, eur];
}

@end

#endif
