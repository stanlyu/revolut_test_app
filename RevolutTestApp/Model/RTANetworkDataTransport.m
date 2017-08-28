//
//  RTANetworkDataTransport.m
//  RevolutTestApp
//
//  Created by Stanislav on 19.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTANetworkDataTransport.h"
#import <AFNetworking/AFNetworking.h>
#import <XMLDictionary/XMLDictionary.h>
#import "RTACurrencyImpl.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const currenciesURLString = @"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
static NSString * const cubeKey = @"Cube";

@interface RTANetworkDataTransport ()

@property AFHTTPSessionManager *currencySessionManager;

@end

@implementation RTANetworkDataTransport

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currencySessionManager = [AFHTTPSessionManager new];
        _currencySessionManager.responseSerializer = AFXMLParserResponseSerializer.serializer;
    }
    return self;
}

- (void)loadCurrenciesWithCompletionHandler:(void (^)(NSArray<id<RTACurrency>> * _Nullable,
                                                      NSError * _Nullable))completionHandler {
    [_currencySessionManager GET:currenciesURLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = [XMLDictionaryParser.sharedInstance dictionaryWithParser:(NSXMLParser *)responseObject];
        NSArray *currenciesRawList = (NSArray *)responseDictionary[cubeKey][cubeKey][cubeKey];
        NSMutableArray<id<RTACurrency>> *currencies = [NSMutableArray new];
        for (NSDictionary<NSString *, NSString *> *currencyDictionary in currenciesRawList) {
            id<RTACurrency> currency = [[RTACurrencyImpl alloc] initWithDictionary:currencyDictionary];
            if (currency) {
                [currencies addObject:currency];
            }
        }
        [currencies addObject:[[RTACurrencyImpl alloc] initWithCode:kEUR rate:DN(1.0)]];
        completionHandler(currencies.copy, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(nil, error);
    }];
}

@end

NS_ASSUME_NONNULL_END
