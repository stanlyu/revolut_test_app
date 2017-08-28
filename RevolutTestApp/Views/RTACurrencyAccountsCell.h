//
//  RTACurrencyAccountsCell.h
//  RevolutTestApp
//
//  Created by Stanislav on 01.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class iCarousel, RTACurrencyAccountView, RTACurrencyAccountsCell;

@protocol RTACurrencyAccountsCellDataSorce <NSObject>

- (NSInteger)numberOfItemsInCurrencyAccountsCell:(RTACurrencyAccountsCell *)cell;
- (RTACurrencyAccountView *)currencyAccountCell:(RTACurrencyAccountsCell *)cell
                             viewForItemAtIndex:(NSInteger)index
                                    reusingView:(nullable RTACurrencyAccountView *)view;

@end

@protocol RTACurrencyAccountsCellDelegate <NSObject>
@optional
- (void)currencyAccountsCellDidBeginEditing:(RTACurrencyAccountsCell *)cell
                            inViewWithIndex:(NSInteger)index;

- (void)currencyAccountsCell:(RTACurrencyAccountsCell *)cell
    didChangeInputNumberText:(NSString *)text
             inViewWithIndex:(NSInteger)index;

- (void)currencyAccountsCellCurrentItemIndexDidChange:(RTACurrencyAccountsCell *)cell;
- (void)currencyAccountsCellDidEndScrollingAnimation:(RTACurrencyAccountsCell *)cell;

@end

@interface RTACurrencyAccountsCell : UITableViewCell

@property (nonatomic, weak) id<RTACurrencyAccountsCellDataSorce> dataSorce;
@property (nonatomic, weak) id<RTACurrencyAccountsCellDelegate> delegate;
@property (nonatomic, assign) NSInteger currentItemIndex;
@property (nonatomic, strong, readonly) RTACurrencyAccountView *currentItemView;
@property (nonatomic, assign, readonly) NSInteger numberOfItems;

- (void)reloadCarousel;
- (void)reloadItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
