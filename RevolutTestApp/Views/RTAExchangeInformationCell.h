//
//  RTAExchangeInformationCell.h
//  RevolutTestApp
//
//  Created by Stanislav on 16.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RTAExchangeInformationCell;

@protocol RTAExchangeInformationCellDelegate <NSObject>

- (void)exchangeInformationCellDidButtonTap:(RTAExchangeInformationCell *)cell;

@end

@interface RTAExchangeInformationCell : UITableViewCell

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy, nullable) NSString *suggestionText;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, weak) id<RTAExchangeInformationCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
