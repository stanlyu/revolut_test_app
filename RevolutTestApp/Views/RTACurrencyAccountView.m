//
//  RTACurrencyAccountView.m
//  RevolutTestApp
//
//  Created by Stanislav on 07.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyAccountView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyAccountView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountChargedTextField;
@property (nonatomic, strong) id<NSObject> observer;

@end

@implementation RTACurrencyAccountView

- (void)awakeFromNib {
    [super awakeFromNib];
    RTACurrencyAccountView * __weak wSelf = self;
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                                  object:_amountChargedTextField
                                                                   queue:nil
                                                              usingBlock:^(NSNotification * _Nonnull note) {
                                                                  RTACurrencyAccountView *sSelf = wSelf;

                                                                  if ([self.delegate respondsToSelector:@selector(currencyAccountViewDidChangeInputNumberText:)]) {
                                                                      [self.delegate currencyAccountViewDidChangeInputNumberText:sSelf];
                                                                  }
                                                              }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    BOOL pointInside = [self pointInside:point withEvent:event];
    return pointInside ? self.superview : [super hitTest:point withEvent:event];
}

- (nullable NSString *)inputNumberText {
    return _amountChargedTextField.text;
}

- (void)setInputNumberText:(nullable NSString *)inputNumberText {
    if (![_amountChargedTextField.text.decimalNumber isEqual:inputNumberText.decimalNumber]) {
        NSDecimalNumber *decimalNumber = inputNumberText.decimalNumber;
        BOOL invalidDecimalNumber = !decimalNumber || [decimalNumber isNotANumber] || [decimalNumber isEqualToDecimalNumber:DN(0)];
        _amountChargedTextField.text = invalidDecimalNumber ? nil : [self.numberFormatter stringFromNumber:decimalNumber];
    }
}

- (BOOL)becomeFirstResponder {
    return [self.amountChargedTextField becomeFirstResponder];
}

- (BOOL)isFirstResponder {
    return self.amountChargedTextField.isFirstResponder;
}

#pragma mark - Private methods
- (BOOL)isValidString:(NSString *)string {
    NSString *regex = [NSString stringWithFormat:@"^%@?(\\d+\\.?\\d{0,2})?$", _type == RTACurrencyAccountViewTypeExpense ? @"\\-" : @"\\+"];
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:string];
}

- (NSString *)inputTextPrefix {
    return _type == RTACurrencyAccountViewTypeExpense ? @"-" : @"+";
}

- (RTANumberFormatter *)numberFormatter {
    return _type == RTACurrencyAccountViewTypeExpense ? RTANumberFormatter.expenseAmountFormatter : RTANumberFormatter.replenishmentAmountFormatter;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = !textField.text ? @"" : textField.text;
    NSString *finalString = [text stringByReplacingCharactersInRange:range withString:string];
    if (![self isValidString:finalString]) {
        return NO;
    }
    
    if (![finalString hasPrefix:self.inputTextPrefix] && finalString.length > 0) {
        textField.text = [self.inputTextPrefix stringByAppendingString:text];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(currencyAccountViewDidBeginEditingInputNumberText:)]) {
        [_delegate currencyAccountViewDidBeginEditingInputNumberText:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0 && [[NSDecimalNumber decimalNumberWithString:textField.text] isEqualToDecimalNumber:(@0).decimalNumber]) {
        textField.text = nil;
    }
}

@end

NS_ASSUME_NONNULL_END
