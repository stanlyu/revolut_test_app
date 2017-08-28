//
//  RTACurrencyAccountImpl.h
//  RevolutTestApp
//
//  Created by Stanislav on 31.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyAccountImpl : NSObject <RTACurrencyAccount>

- (instancetype)initWithCurrency:(id<RTACurrency>)currency funds:(NSDecimalNumber *)funds NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
