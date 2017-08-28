//
//  NSDecimalNumber+Addition.h
//  RevolutTestApp
//
//  Created by Stanislav on 15.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (Addition)

@property (nonatomic, readonly, copy) NSDecimalNumber *absolute;
@property (nonatomic, readonly, copy) NSDecimalNumber *negative;

@end

NS_ASSUME_NONNULL_END
