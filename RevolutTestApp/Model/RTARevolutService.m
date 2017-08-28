//
//  RTARevolutService.m
//  RevolutTestApp
//
//  Created by Stanislav on 30.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTARevolutService.h"
#import "RTACurrencyImpl.h"
#import "RTACurrencyAccountImpl.h"
#import "RTAExchangeOperationImpl.h"
#import "RTANetworkDataTransport.h"

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer,
                                  dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC),
                                  interval * NSEC_PER_SEC,
                                  (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

NS_ASSUME_NONNULL_BEGIN

NSNotificationName const RTARevolutServiceDidChangeStateNotification = @"RTARevolutServiceDidChangeState";
NSNotificationName const RTARevoluteServiceDidChangeCurrencyAccountsNotification = @"RTARevoluteServiceDidChangeCurrencyAccounts";

static NSString * const oldAccountsKey = @"old";
static NSString * const newAccountsKey = @"new";

static const NSTimeInterval updatingRatesTimeInterval = 30.f;

@interface RTARevolutService ()

@property (assign) RTARevolutServiceState state;
@property NSMutableArray<RTAExchangeOperationCompletionHandler> *providingOperationQueue;
@property (readwrite) NSArray<id<RTACurrencyAccount>> *currencyAccounts;
@property NSError *lastError;
@property dispatch_source_t timer;
@property dispatch_queue_t ratesPollingQueue;
@property id<RTADataTransport> dataTransport;

@end

@implementation RTARevolutService {
    RTARevolutServiceState _state;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RTARevolutService *revolutService;
    dispatch_once(&onceToken, ^{
        revolutService = [[RTARevolutService alloc] initPrivate];
    });
    return  revolutService;
}

- (void)dealloc {
    [self stopUpdatingRates];
}

#pragma mark - Public methods
- (RTARevolutServiceState)state {
    RTARevolutServiceState state;
    @synchronized (self) {
        state = _state;
    }
    return state;
}

- (void)setState:(RTARevolutServiceState)state {
    @synchronized (self) {
        if (_state != state) {
            _state = state;
            if (_state == RTARevolutServiceStateIdle) {
                [self.providingOperationQueue enumerateObjectsUsingBlock:^(RTAExchangeOperationCompletionHandler  _Nonnull handler, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self provideExchangeOperationWithCompletionHandler:handler];
                }];
            } else if (_state == RTARevolutServiceStateNotInitialized) {
                [self.providingOperationQueue enumerateObjectsUsingBlock:^(RTAExchangeOperationCompletionHandler  _Nonnull handler, NSUInteger idx, BOOL * _Nonnull stop) {
                    handler(nil, _lastError);
                }];
            }
            [self.providingOperationQueue removeAllObjects];
        }
    }
}

- (void)start {
    if (self.state != RTARevolutServiceStateNotInitialized) {
        return;
    }
    self.state = RTARevolutServiceStateInitializing;
    RTARevolutService __weak *wSelf = self;
    [self loadAccountsWithCompletionHandler:^(NSArray<id<RTACurrencyAccount>> * _Nullable accounts, NSError * _Nullable error) {
        if (accounts.count > 0) {
            wSelf.currencyAccounts = accounts;
            wSelf.state = RTARevolutServiceStateIdle;
            [wSelf startUpdatingRates];
            [wSelf subscribeOnApplicationNotifications];
        } else {
            wSelf.lastError = !error ? NSError.noAccountsError : NSError.connectionFailureError;
            wSelf.state = RTARevolutServiceStateNotInitialized;
        }
    }];
}

- (BOOL)isInitialized {
    NSSet<NSNumber *> *states = [NSSet setWithArray:@[@(RTARevolutServiceStateInitializing), @(RTARevolutServiceStateNotInitialized)]];
    return ![states containsObject:@(self.state)];
}

- (BOOL)isInitializing {
    return self.state == RTARevolutServiceStateInitializing;
}

- (void)provideExchangeOperationWithCompletionHandler:(RTAExchangeOperationCompletionHandler)completionHandler {
    switch (_state) {
        case RTARevolutServiceStateNotInitialized: {
            completionHandler(nil, self.lastError ? self.lastError : NSError.noAccountsError);
            return;
        }
        case RTARevolutServiceStateInitializing:
        case RTARevolutServiceStateExchangeOperationInProgress: {
            [self.providingOperationQueue addObject:completionHandler];
            return;
        }
        default:
            break;
    }
    
    NSInteger replenishmentAccountIndex = 1 % self.currencyAccounts.count;
    id<RTAExchangeOperation> exchangeOperation = [[RTAExchangeOperationImpl alloc] initWithExpenseAccount:self.currencyAccounts[0]
                                                                 replenishmentAccount:self.currencyAccounts[replenishmentAccountIndex]];
    completionHandler(exchangeOperation, nil);
}

- (void)executeExchangeOperation:(id<RTAExchangeOperation>)operation
           withCompletionHandler:(RTAExchangeOperationCompletionHandler)completionHandler {
    if (operation.validationError) {
        completionHandler(nil, operation.validationError);
        return;
    }
    
    self.state = RTARevolutServiceStateExchangeOperationInProgress;
    NSInteger expenseIndex = [self.currencyAccounts indexOfObject:operation.expenseAccount];
    NSInteger replenishmentIndex = [self.currencyAccounts indexOfObject:operation.replenishmentAccount];
    [operation makeExchange];
    NSMutableArray<id<RTACurrencyAccount>> *accounts = self.currencyAccounts.mutableCopy;
    accounts[expenseIndex] = operation.expenseAccount.copy;
    accounts[replenishmentIndex] = operation.replenishmentAccount.copy;
    self.currencyAccounts = accounts.copy;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = RTARevolutServiceStateIdle;
        completionHandler(operation, nil);
    });
}

#pragma mark - Private methods
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _currencyAccounts = @[];
        _usedCurrencyCodes = @[kEUR, kGBP, kUSD];
        _providingOperationQueue = [NSMutableArray new];
        _ratesPollingQueue = dispatch_queue_create("com.polling.revolut", NULL);
        _dataTransport = [RTANetworkDataTransport new];
    }
    return self;
}

- (void)loadAccountsWithCompletionHandler:(void (^)(NSArray<id<RTACurrencyAccount>> * _Nullable accounts,
                                                    NSError * _Nullable error))completionHandler {
    [self.dataTransport loadCurrenciesWithCompletionHandler:^(NSArray<id<RTACurrency>> * _Nullable currencies, NSError * _Nullable error) {
        NSArray<id<RTACurrency>> *filteredCurrencies = [currencies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code in %@", self.usedCurrencyCodes]];
        NSArray<id<RTACurrencyAccount>> *accounts = [RTARevolutService.sharedInstance accountsWithCurrencies:filteredCurrencies];
        completionHandler(accounts, error);
    }];
}

- (nullable NSArray<id<RTACurrencyAccount>> *)accountsWithCurrencies:(NSArray<id<RTACurrency>> *)currencies {
    NSMutableArray<id<RTACurrencyAccount>> *accounts = @[].mutableCopy;
    [currencies enumerateObjectsUsingBlock:^(id<RTACurrency>  _Nonnull currency, NSUInteger idx, BOOL * _Nonnull stop) {
        [accounts addObject:[RTARevolutService accountWithCurrency:currency]];
    }];
    return accounts.copy;
}

+ (id<RTACurrencyAccount>)accountWithCurrency:(id<RTACurrency>)currency {
    NSInteger index = [RTARevolutService.sharedInstance.currencyAccounts indexOfObjectPassingTest:^BOOL(id<RTACurrencyAccount>  _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account.currency.code isEqualToString:currency.code]) {
            *stop = YES;
        }
        return *stop;
    }];
    
    if (index != NSNotFound) {
        id<RTACurrencyAccount> account = RTARevolutService.sharedInstance.currencyAccounts[index].copy;
        account.currency = currency;
        return account;
    }
    return [[RTACurrencyAccountImpl alloc] initWithCurrency:currency funds:DN(100.0)];
}

- (void)startUpdatingRates {
    if (!_timer) {
        _timer = CreateDispatchTimer(updatingRatesTimeInterval, _ratesPollingQueue, ^{
            [RTARevolutService.sharedInstance loadAccountsWithCompletionHandler:^(NSArray<id<RTACurrencyAccount>> * _Nullable accounts, NSError * _Nullable error) {
                if (error || !accounts.count) {
                    return;
                }
                [RTARevolutService.sharedInstance updateWithNewAccounts:accounts];
            }];
        });
    }
}

- (void)stopUpdatingRates {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)updateWithNewAccounts:(NSArray<id<RTACurrencyAccount>> *)accounts {
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"currency.code" ascending:YES];
    NSArray<id<RTACurrencyAccount>> *newAccounts = [accounts sortedArrayUsingDescriptors:@[descriptor]];
    NSArray<id<RTACurrencyAccount>> *oldAccounts = [RTARevolutService.sharedInstance.currencyAccounts sortedArrayUsingDescriptors:@[descriptor]];
    if (![newAccounts isEqualToArray:oldAccounts]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RTARevolutService.sharedInstance.currencyAccounts = newAccounts;
            [NSNotificationCenter.defaultCenter postNotificationName:RTARevoluteServiceDidChangeCurrencyAccountsNotification
                                                              object:RTARevolutService.sharedInstance
                                                            userInfo:@{oldAccountsKey : oldAccounts,
                                                                       newAccountsKey : newAccounts}];
        });
    }
}

- (void)subscribeOnApplicationNotifications {
    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillResignActiveNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification * _Nonnull note) {
                                                    [self stopUpdatingRates];
                                                }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillEnterForegroundNotification
                                                    object:nil queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification * _Nonnull note) {
                                                    [RTARevolutService.sharedInstance loadAccountsWithCompletionHandler:^(NSArray<id<RTACurrencyAccount>> * _Nullable accounts, NSError * _Nullable error) {
                                                        if (!error && accounts.count > 0) {
                                                            [RTARevolutService.sharedInstance updateWithNewAccounts:accounts];
                                                        }
                                                        [self startUpdatingRates];
                                                    }];
                                                }];
}

@end

NS_ASSUME_NONNULL_END
