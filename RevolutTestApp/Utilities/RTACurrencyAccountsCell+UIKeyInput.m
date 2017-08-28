//
//  RTACurrencyAccountsCell+UIKeyInput.m
//  RevolutTestApp
//
//  Created by Stanislav on 16.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyAccountsCell+UIKeyInput.h"

@implementation RTACurrencyAccountsCell (UIKeyInput)

#pragma mark - UIKeyInput

- (BOOL)hasText {
    return NO;
}

- (void)insertText:(NSString *)text {}

- (void)deleteBackward {}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeDecimalPad;
}

@end
