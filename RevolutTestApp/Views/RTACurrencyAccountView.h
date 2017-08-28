//
//  RTACurrencyAccountView.h
//  RevolutTestApp
//
//  Created by Stanislav on 07.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RTACurrencyAccountViewType) {
    RTACurrencyAccountViewTypeExpense,
    RTACurrencyAccountViewTypeReplenishment
};

@class RTACurrencyAccountView;

NS_ASSUME_NONNULL_BEGIN

@protocol RTACurrencyAccountViewDelegate <NSObject>
@optional
- (void)currencyAccountViewDidChangeInputNumberText:(RTACurrencyAccountView *)view;
- (void)currencyAccountViewDidBeginEditingInputNumberText:(RTACurrencyAccountView *)view;

@end

@interface RTACurrencyAccountView : UIView
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *fundLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (copy, nonatomic, nullable) NSString *inputNumberText;

@property (assign, nonatomic) RTACurrencyAccountViewType type;
@property (weak, nonatomic) id<RTACurrencyAccountViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
