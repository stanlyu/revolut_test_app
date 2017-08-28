//
//  RTACurrencyExchangeViewController.h
//  RevolutTestApp
//
//  Created by Stanislav on 28.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RTAAccountRow) {
    RTAAccountRowExpense,
    RTAAccountRowReplenishment,
    RTAAccountRowsCount
};

typedef NS_ENUM(NSUInteger, RTAExchangeSection) {
    RTAExchangeSectionAccounts,
    RTAExchangeSectionInfo
};

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyExchangeViewController : UITableViewController

@end

NS_ASSUME_NONNULL_END

