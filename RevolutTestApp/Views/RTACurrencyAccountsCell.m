//
//  RTACurrencyAccountsCell.m
//  RevolutTestApp
//
//  Created by Stanislav on 01.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyAccountsCell.h"
#import <iCarousel/iCarousel.h>
#import "RTACurrencyAccountView.h"
#import "RTACurrencyAccountsCell+UIKeyInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyAccountsCell () <iCarouselDataSource, iCarouselDelegate, RTACurrencyAccountViewDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carouselView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation RTACurrencyAccountsCell

#pragma mark - Public methods

- (void)awakeFromNib {
    [super awakeFromNib];
    _carouselView.pagingEnabled = YES;
    _carouselView.scrollSpeed = 0.7;
    for (UIGestureRecognizer *gr in _carouselView.contentView.gestureRecognizers) {
        gr.cancelsTouchesInView = NO;
    }
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)currentItemIndex {
    return _carouselView.currentItemIndex;
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex {
    if (self.currentItemIndex != currentItemIndex) {
        [_carouselView setCurrentItemIndex:currentItemIndex];
    }
}

- (RTACurrencyAccountView *)currentItemView {
    return (RTACurrencyAccountView *)_carouselView.currentItemView;
}

- (NSInteger)numberOfItems {
    return _carouselView.numberOfItems;
}

- (void)reloadCarousel {
    [_carouselView reloadData];
}

- (void)reloadItemAtIndex:(NSInteger)index {
    [_carouselView reloadItemAtIndex:index animated:NO];
}

- (BOOL)becomeFirstResponder {
    if (_carouselView.dragging || _carouselView.decelerating) {
        return NO;
    }
    return [self.currentItemView becomeFirstResponder];
}

- (IBAction)pageControlDidValueChange:(UIPageControl *)sender {
    [_carouselView scrollToItemAtIndex:sender.currentPage animated:YES];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (!_dataSorce) {
        _pageControl.numberOfPages = 0;
        return 0;
    }
    
    if (![_dataSorce conformsToProtocol:@protocol(RTACurrencyAccountsCellDataSorce) ]) {
        RTAFailureAssert(@"Data source (%@) doesn't conform to RTACurrencyAccountsCellDataSorce protocol", _dataSorce);
        _pageControl.numberOfPages = 0;
        return 0;
    }
    
    _pageControl.numberOfPages = [_dataSorce numberOfItemsInCurrencyAccountsCell:self];
    return _pageControl.numberOfPages;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view {
    if (!_dataSorce) {
        return nil;
    }
    
    if (![_dataSorce conformsToProtocol:@protocol(RTACurrencyAccountsCellDataSorce) ]) {
        RTAFailureAssert(@"Data source (%@) doesn't conform to RTACurrencyAccountsCellDataSorce protocol", _dataSorce);
        return nil;
    }
    
    RTACurrencyAccountView *currencyAccountView = [_dataSorce currencyAccountCell:self
                                                               viewForItemAtIndex:index
                                                                      reusingView:(RTACurrencyAccountView *)view];
    if (currencyAccountView != nil && ![currencyAccountView isKindOfClass:RTACurrencyAccountView.class]) {
        RTAFailureAssert(@"It has been returned incompatible view type %@ instead of RTACurrencyAccountView for %@", NSStringFromClass(currencyAccountView.class), NSStringFromSelector(@selector(currencyAccountCell:viewForItemAtIndex:reusingView:)));
        return nil;
    }
    currencyAccountView.delegate = self;
    return currencyAccountView;
}

#pragma mark - iCarouselDelegate

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    _pageControl.currentPage = carousel.currentItemIndex;
    if ([_delegate respondsToSelector:@selector(currencyAccountsCellCurrentItemIndexDidChange:)]) {
        [_delegate currencyAccountsCellCurrentItemIndexDidChange:self];
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    //----------------------------------------------------------
    // restore current item view as first responder
    if (self.isFirstResponder) {
        [self.currentItemView becomeFirstResponder];
    }
    //----------------------------------------------------------
    if ([_delegate respondsToSelector:@selector(currencyAccountsCellDidEndScrollingAnimation:)]) {
        [_delegate currencyAccountsCellDidEndScrollingAnimation:self];
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    //----------------------------------------------------------
    // prevent hiding the keyboard when changing the current item view
    if (self.currentItemView.isFirstResponder) {
        [super becomeFirstResponder];
    }
    //----------------------------------------------------------
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return self.bounds.size.width;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    CGFloat newValue = value;
    switch (option) {
        case iCarouselOptionWrap:
            newValue = YES;
            break;
        case iCarouselOptionOffsetMultiplier:
            newValue = 0.5;
            break;
        default:
            break;
    }
    return newValue;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    [self becomeFirstResponder];
}

#pragma mark - RTACurrencyAccountViewDelegate

- (void)currencyAccountViewDidBeginEditingInputNumberText:(RTACurrencyAccountView *)view {
    if ([_delegate respondsToSelector:@selector(currencyAccountsCellDidBeginEditing:inViewWithIndex:)]) {
        [_delegate currencyAccountsCellDidBeginEditing:self inViewWithIndex:_carouselView.currentItemIndex];
    }
}

- (void)currencyAccountViewDidChangeInputNumberText:(RTACurrencyAccountView *)view {
    if (_carouselView.currentItemView == view &&
        [_delegate respondsToSelector:@selector(currencyAccountsCell:didChangeInputNumberText:inViewWithIndex:)]) {
        [_delegate currencyAccountsCell:self
               didChangeInputNumberText:view.inputNumberText
                        inViewWithIndex:_carouselView.currentItemIndex];
    }
}

@end

NS_ASSUME_NONNULL_END
