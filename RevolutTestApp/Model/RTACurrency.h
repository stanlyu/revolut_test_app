//
//  RTACurrency.h
//  RevolutTestApp
//
//  Created by Stanislav on 28.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

// Currencies codes
extern NSString * _Nonnull const kEUR;
extern NSString * _Nonnull const kGBP;
extern NSString * _Nonnull const kUSD;

// Currencies signs
extern NSString * _Nonnull const kEURSign;
extern NSString * _Nonnull const kGBPSign;
extern NSString * _Nonnull const kUSDSign;

NS_ASSUME_NONNULL_BEGIN

@protocol RTACurrency <NSObject, NSCopying>

@property (copy) NSString *code;
@property (copy, readonly) NSString *sign;
@property (copy) NSDecimalNumber *rate;
@property (readonly) id copy;

- (NSDecimalNumber *)rateByCurrency:(id<RTACurrency>)anotherCurrency;

@end

NS_ASSUME_NONNULL_END
