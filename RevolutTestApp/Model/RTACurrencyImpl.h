//
//  RTACurrencyImpl.h
//  RevolutTestApp
//
//  Created by Stanislav on 28.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrency.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyImpl : NSObject <RTACurrency>

- (instancetype)initWithCode:(NSString *)code rate:(NSDecimalNumber *)rate NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
