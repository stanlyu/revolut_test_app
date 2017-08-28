//
//  RTAExchangeInformationCell.m
//  RevolutTestApp
//
//  Created by Stanislav on 16.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTAExchangeInformationCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTAExchangeInformationCell ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *suggestionLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation RTAExchangeInformationCell

#pragma mark - public methods

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _button.layer.cornerRadius = 3.0;
    _button.clipsToBounds = YES;
}

- (NSString *)text {
    return _descriptionLabel.text ? _descriptionLabel.text : @"";
}

- (void)setText:(NSString *)text {
    NSParameterAssert(text);
    if (!text) {
        return;
    }
    if (![_descriptionLabel.text isEqualToString:text]) {
        _descriptionLabel.text = text;
    }
}

- (nullable NSString *)suggestionText {
    return _suggestionLabel.text;
}

- (void)setSuggestionText:(nullable NSString *)suggestionText {
    _suggestionLabel.text = suggestionText;
    _suggestionLabel.hidden = !suggestionText.length;
}

- (NSString *)buttonTitle {
    return [_button titleForState:UIControlStateNormal];
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    NSParameterAssert(buttonTitle);
    if (!buttonTitle) {
        return;
    }
    
    if (![self.buttonTitle isEqualToString:buttonTitle]) {
        [_button setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

#pragma mark - private methods

- (IBAction)didTap:(UIButton *)sender {
    [self.delegate exchangeInformationCellDidButtonTap:self];
}

@end

NS_ASSUME_NONNULL_END
