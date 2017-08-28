//
//  NSError+RTA.m
//  RevolutTestApp
//
//  Created by Stanislav on 18.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "NSError+RTA.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const RTAErrorDomain = @"RTAErrorDomain";

@implementation NSError (RTA)

+ (NSError *)noAccountsError {
    return [NSError errorWithDomain:RTAErrorDomain
                               code:RTACurrencyAccountsNotFoundErrorCode
                           userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"No currency accounts could be loaded. ", nil),
                                      NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please try again later.", nil),
                                      NSLocalizedRecoveryOptionsErrorKey : @[NSLocalizedString(@"Retry", nil)]}];
}

+ (NSError *)connectionFailureError {
    return [NSError errorWithDomain:RTAErrorDomain
                               code:RTAConnectionFailureErrorCode
                           userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"There could not connect to the server", nil),
                                      NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please try again.", nil),
                                      NSLocalizedRecoveryOptionsErrorKey : @[NSLocalizedString(@"Retry", nil)]}];
}

+ (NSError *)insufficientFundsError {
    return [NSError errorWithDomain:RTAErrorDomain
                               code:RTAInsufficientFundsErrorCode
                           userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Insufficient funds for the exchange operation.", nil),
                                      NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"It is necessary to reduce the charge amount.", nil),
                                      NSLocalizedRecoveryOptionsErrorKey : @[NSLocalizedString(@"OK", nil)]}];
}

+ (NSError *)sameAccountsError {
    return [NSError errorWithDomain:RTAErrorDomain
                               code:RTASameAccountsErrorCode
                           userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"The exchange operation can not be performed.", nil),
                                      NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please change the expense account or the replenishment, so that they differ.", nil),
                                      NSLocalizedRecoveryOptionsErrorKey : @[NSLocalizedString(@"OK", nil)]}];
}

+ (NSError *)lackOfFundsError {
    return [NSError errorWithDomain:RTAErrorDomain
                               code:RTALackOfFundsErrorCode
                           userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Lack of funds for exchange.", nil),
                                      NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please determine the amount of funds for writing off or replenishment.", nil),
                                      NSLocalizedRecoveryOptionsErrorKey : @[NSLocalizedString(@"OK", nil)]}];
}

@end

NS_ASSUME_NONNULL_END
