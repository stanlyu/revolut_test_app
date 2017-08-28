//
//  RTACurrencyExchangeViewController+UITableView.m
//  RevolutTestApp
//
//  Created by Stanislav on 20.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyExchangeViewController+UITableView.h"
#import "RTACurrencyAccountsCell.h"
#import <KVOMutableArray/KVOMutableArray.h>
#import "RTAExchangeInformationCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyExchangeViewController () <RTACurrencyAccountsCellDataSorce, RTACurrencyAccountsCellDelegate, RTAExchangeInformationCellDelegate>

@property (nonatomic, strong) KVOMutableArray<NSNumber *> *sections;
@property (nonatomic, copy, nullable) NSError *error;
@property (nonatomic, readonly) NSUInteger indexOfAccountsSection;
@property (nonatomic, readonly) NSUInteger indexOfInfoSection;

- (void)reloadCurrancyAccountCell:(RTACurrencyAccountsCell *)cell;
- (NSInteger)currentAccountIndexForRow:(RTAAccountRow)row;

@end

@implementation RTACurrencyExchangeViewController (UITableView)

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.indexOfInfoSection) {
        return 1;
    }
    return RTARevolutService.sharedInstance.currencyAccounts.count > 0 ? RTAAccountRowsCount : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.indexOfAccountsSection) {
        RTACurrencyAccountsCell *cell = [tableView dequeueReusableCellWithIdentifier:RTACurrencyAccountsCell.defaultReuseIdentifier];
        cell.tag = indexPath.row;
        cell.dataSorce = self;
        cell.delegate = self;
        cell.separatorInset = UIEdgeInsetsMake(0, !indexPath.row ? 0 : 2000, 0, 0);
        [self reloadCurrancyAccountCell:cell];
        return cell;
    } else {
        RTAExchangeInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:RTAExchangeInformationCell.defaultReuseIdentifier];
        cell.text = self.error.localizedDescription;
        cell.suggestionText = self.error.localizedRecoverySuggestion;
        cell.buttonTitle = self.error.localizedRecoveryOptions.firstObject;
        cell.delegate = self;
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.indexOfAccountsSection) {
        RTACurrencyAccountsCell *currencyAccountsCell = (RTACurrencyAccountsCell *)cell;
        currencyAccountsCell.currentItemIndex = [self currentAccountIndexForRow:cell.tag];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.indexOfAccountsSection) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
    }
}

@end

NS_ASSUME_NONNULL_END
