//
//  RTADataTransport.h
//  RevolutTestApp
//
//  Created by Stanislav on 19.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTACurrency;

NS_ASSUME_NONNULL_BEGIN

@protocol RTADataTransport <NSObject>

- (void)loadCurrenciesWithCompletionHandler:(void (^)(NSArray<id<RTACurrency>> * _Nullable currencies,
                                                      NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
