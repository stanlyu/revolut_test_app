//
//  NSError+RTA.h
//  RevolutTestApp
//
//  Created by Stanislav on 18.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const RTAErrorDomain;

typedef NS_ENUM(NSUInteger, RTAErrorCode) {
    RTAInsufficientFundsErrorCode = 1000,
    RTACurrencyAccountsNotFoundErrorCode = 1001,
    RTAConnectionFailureErrorCode = 1002,
    RTASameAccountsErrorCode = 1003,
    RTALackOfFundsErrorCode = 1004
};

@interface NSError (RTA)

@property (nonatomic, readonly, class) NSError *noAccountsError;
@property (nonatomic, readonly, class) NSError *connectionFailureError;
@property (nonatomic, readonly, class) NSError *insufficientFundsError;
@property (nonatomic, readonly, class) NSError *sameAccountsError;
@property (nonatomic, readonly, class) NSError *lackOfFundsError;

@end

NS_ASSUME_NONNULL_END
