//
//  RTACurrencyAccount.h
//  RevolutTestApp
//
//  Created by Stanislav on 30.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrency.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RTACurrencyAccount <NSObject, NSCopying>

@property (copy) id<RTACurrency> currency;
@property (copy) NSDecimalNumber *funds;
@property (readonly) id copy;

@end

NS_ASSUME_NONNULL_END
