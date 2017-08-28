//
//  RTARevolutService.h
//  RevolutTestApp
//
//  Created by Stanislav on 30.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTACurrencyAccount.h"
#import "RTAExchangeOperation.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const RTARevoluteServiceDidChangeCurrencyAccountsNotification;

typedef NS_ENUM(NSUInteger, RTARevolutServiceState) {
    RTARevolutServiceStateNotInitialized,
    RTARevolutServiceStateInitializing,
    RTARevolutServiceStateIdle,
    RTARevolutServiceStateExchangeOperationInProgress
};

@class RTARevolutService;

typedef void(^RTAExchangeOperationCompletionHandler)(id<RTAExchangeOperation> _Nullable exchangeOperation,
NSError * _Nullable error);

@interface RTARevolutService : NSObject

@property (readonly) NSArray<id<RTACurrencyAccount>> *currencyAccounts;
@property (nullable) NSArray<NSString *> *usedCurrencyCodes;
@property (assign, readonly) BOOL isInitialized;
@property (assign, readonly) BOOL isInitializing;

+ (instancetype)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)provideExchangeOperationWithCompletionHandler:(RTAExchangeOperationCompletionHandler)completionHandler;
- (void)executeExchangeOperation:(id<RTAExchangeOperation>)operation
           withCompletionHandler:(RTAExchangeOperationCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
