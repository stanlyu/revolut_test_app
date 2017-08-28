//
//  RTACurrencyExchangeViewController+RTACurrencyAccountsCell.m
//  RevolutTestApp
//
//  Created by Stanislav on 20.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyExchangeViewController+RTACurrencyAccountsCell.h"
#import <KVOMutableArray/KVOMutableArray.h>
#import "RTACurrencyAccountView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyExchangeViewController ()

@property (nonatomic) id<RTAExchangeOperation> exchangeOperation;
@property (nonatomic, assign) RTAAccountRow selectedAccountRow;

- (void)configureView:(RTACurrencyAccountView *)view withExpenseAccount:(id<RTACurrencyAccount>)expenseAccount;
- (void)configureView:(RTACurrencyAccountView *)view withReplenishmentAccount:(id<RTACurrencyAccount>)replenishmentAccount;
- (NSInteger)currentAccountIndexForRow:(RTAAccountRow)row;
- (void)updateExpense;
- (void)updateReplenishment;
- (nullable RTACurrencyAccountsCell *)selectedAccountsCell;

@end

@implementation RTACurrencyExchangeViewController (RTACurrencyAccountsCell)

#pragma mark - RTACurrencyAccountsCellDataSorce

- (NSInteger)numberOfItemsInCurrencyAccountsCell:(RTACurrencyAccountsCell *)cell {
    return RTARevolutService.sharedInstance.currencyAccounts.count;
}

- (RTACurrencyAccountView *)currencyAccountCell:(RTACurrencyAccountsCell *)cell
                             viewForItemAtIndex:(NSInteger)index
                                    reusingView:(nullable RTACurrencyAccountView *)view {
    RTACurrencyAccountView *currencyAccountView = view;
    
    if (!currencyAccountView) {
        currencyAccountView = [[[UINib nibWithNibName:RTACurrencyAccountView.defaultNibName
                                               bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    }
    
    currencyAccountView.rateLabel.text = nil;
    currencyAccountView.inputNumberText = nil;
    CGRect frame = currencyAccountView.frame;
    frame.size.width = cell.bounds.size.width;
    currencyAccountView.frame = frame;
    
    id<RTACurrencyAccount> currencyAccount = RTARevolutService.sharedInstance.currencyAccounts[index];
    switch (cell.tag) {
        case RTAAccountRowExpense: {
            [self configureView:currencyAccountView withExpenseAccount:currencyAccount];
            break;
        }
        default: {
            [self configureView:currencyAccountView withReplenishmentAccount:currencyAccount];
            break;
        }
    }
    
    if (cell.tag == self.selectedAccountRow && [self currentAccountIndexForRow:cell.tag] == index) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell becomeFirstResponder];
        });
    }
    
    return currencyAccountView;
}

#pragma mark - RTACurrencyAccountsCellDelegate

- (void)currencyAccountsCellDidBeginEditing:(RTACurrencyAccountsCell *)cell
                            inViewWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.selectedAccountRow = indexPath.row;
}

- (void)currencyAccountsCell:(RTACurrencyAccountsCell *)cell didChangeInputNumberText:(NSString *)text inViewWithIndex:(NSInteger)index {
    id<RTACurrencyAccount> changedAccount = RTARevolutService.sharedInstance.currencyAccounts[index];
    switch (cell.tag) {
        case RTAAccountRowExpense:
            NSAssert([self.exchangeOperation.expenseAccount isEqual:changedAccount], @"The modified currency account doesn't correspond to the current currency account");
            if (![self.exchangeOperation.expenseAccount isEqual:changedAccount]) {
                return;
            }
            self.exchangeOperation.amountCharged = text.decimalNumber.isNotANumber ? DN(0) : text.decimalNumber.absolute;
            break;
            
        default:
            NSAssert([self.exchangeOperation.replenishmentAccount isEqual:changedAccount], @"The modified currency account doesn't correspond to the current currency account");
            if (![self.exchangeOperation.replenishmentAccount isEqual:changedAccount]) {
                return;
            }
            self.exchangeOperation.amountOfReplenishment = text.decimalNumber.isNotANumber ? DN(0) : text.decimalNumber;
            break;
    }
    [self updateExpense];
    [self updateReplenishment];
}

- (void)currencyAccountsCellDidEndScrollingAnimation:(RTACurrencyAccountsCell *)cell {
    if ([self currentAccountIndexForRow:cell.tag] != cell.currentItemIndex) {
        id<RTACurrencyAccount> newAccount = RTARevolutService.sharedInstance.currencyAccounts[cell.currentItemIndex];
        switch (cell.tag) {
            case RTAAccountRowExpense: {
                self.exchangeOperation.expenseAccount = newAccount;
                break;
            }
            default: {
                self.exchangeOperation.replenishmentAccount = newAccount;
                break;
            }
        }
        
        [self updateExpense];
        [self updateReplenishment];
        [self.selectedAccountsCell becomeFirstResponder];
    }
}

@end

NS_ASSUME_NONNULL_END
