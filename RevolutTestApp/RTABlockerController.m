//
//  RTABlockerController.m
//  RevolutTestApp
//
//  Created by Stanislav on 10.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTABlockerController.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

static const NSTimeInterval minimalShowingTimeInterval = 1.0;
static const CGFloat activityIndicatorViewSize = 50.0;
static const CGFloat titleLabelVerticalOffset = 30.0;

NS_ASSUME_NONNULL_BEGIN

@interface RTABlockerController ()

@property (nonatomic, strong, nullable) NSDate *dateOfBegining;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, strong, readonly) UIView *blockerView;

@end

@implementation RTABlockerController {
    UIView *_blockerView;
    DGActivityIndicatorView *_activityIndicatorView;
    UILabel *_titleLabel;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RTABlockerController *loaderController;
    dispatch_once(&onceToken, ^{
        loaderController = [super new];
    });
    return  loaderController;
}

- (void)show {
    _counter++;
    self.dateOfBegining = [NSDate date];
    
    if (_counter == 1) {
        self.blockerView.alpha = 0.0;
        [UIApplication.sharedApplication.keyWindow addSubview:self.blockerView];
        [UIView animateWithDuration:2.0 animations:^{
            self.blockerView.alpha = 1.0;
        }];
        [_activityIndicatorView startAnimating];
    }
    
}

- (void)hide {
    [self hideWithCompletionHandler:nil];
}

- (void)hideWithCompletionHandler:(nullable RTALoaderControllerCompletionHandler)completionHandler {
    if (_counter - 1 == 0) { // Hide
        NSDate *now = [NSDate date];
        NSTimeInterval timePassed = [now timeIntervalSinceDate:_dateOfBegining];
        if (timePassed >= minimalShowingTimeInterval) {
            _counter--;
            _dateOfBegining = nil;
            [_activityIndicatorView stopAnimating];
            [UIView animateWithDuration:2.0 animations:^{
                self.blockerView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.blockerView removeFromSuperview];
                if (completionHandler) {
                    completionHandler();
                }
            }];
        } else {
            NSTimeInterval remainingTime = minimalShowingTimeInterval - timePassed;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainingTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideWithCompletionHandler:completionHandler];
            });
        }
    } else if (_counter - 1 > 0) {
        _counter--;
    }
}

#pragma mark - Private methods
- (UIView *)blockerView {
    if (!_blockerView) {
        _blockerView = [[UIView alloc] initWithFrame:UIApplication.sharedApplication.keyWindow.bounds];
        _blockerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        _blockerView.userInteractionEnabled = NO;
        _activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallSpinFadeLoader
                                                                                             tintColor:[UIColor whiteColor]
                                                                                                  size:activityIndicatorViewSize];
        [_blockerView addSubview:_activityIndicatorView];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [_activityIndicatorView.centerXAnchor constraintEqualToAnchor:_blockerView.centerXAnchor].active = YES;
        [_activityIndicatorView.bottomAnchor constraintEqualToAnchor:_blockerView.centerYAnchor].active = YES;
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = NSLocalizedString(@"Please wait ...", nil);
        [_blockerView addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel.centerXAnchor constraintEqualToAnchor:_blockerView.centerXAnchor].active = YES;
        [_titleLabel.topAnchor constraintEqualToAnchor:_activityIndicatorView.bottomAnchor constant:titleLabelVerticalOffset].active = YES;
    }
    return _blockerView;
}

@end


NS_ASSUME_NONNULL_END
