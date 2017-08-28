//
//  ViewController.m
//  RevolutTestApp
//
//  Created by Stanislav on 28.08.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "RTACurrencyExchangeViewController.h"
#import "RTACurrencyAccountsCell.h"
#import "RTACurrencyAccount.h"
#import "RTACurrencyAccountView.h"
#import "RTAExchangeOperationImpl.h"
#import <KVOMutableArray/KVOMutableArray.h>
#import "NSArray+KVOMutableArray.h"
#import "RTAExchangeInformationCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTACurrencyExchangeViewController () <RTAExchangeOperationDelegate, RTAExchangeInformationCellDelegate>

@property (nonatomic) id<RTAExchangeOperation> exchangeOperation;
@property (nonatomic, assign) RTAAccountRow selectedAccountRow;
@property (nonatomic, strong) KVOMutableArray<NSNumber *> *sections;
@property (nonatomic, copy, nullable) NSError *error;
@property (nonatomic) AMBlockToken *token;
@property (nonatomic, readonly) NSUInteger indexOfAccountsSection;
@property (nonatomic, readonly) NSUInteger indexOfInfoSection;

@end

@implementation RTACurrencyExchangeViewController

#pragma mark - Initializers

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_token removeObserver];
}

#pragma mark - View cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (RTARevolutService.sharedInstance.isInitializing) {
        [RTABlockerController.sharedInstance show];
    }
}

#pragma mark - RTAExchangeInformationCellDelegate

- (void)exchangeInformationCellDidButtonTap:(RTAExchangeInformationCell *)cell {
    if (!RTARevolutService.sharedInstance.isInitialized) {
        [RTABlockerController.sharedInstance show];
        [self setup];
    } else {
        self.error = nil;
        self.sections[0] = @(RTAExchangeSectionAccounts);
    }
}

#pragma mark - RTAExchangeOperationDelegate

- (void)exchangeOperationDidChange:(id<RTAExchangeOperation>)operation {
    if (self.indexOfAccountsSection != NSNotFound) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.indexOfAccountsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (nullable id<RTACurrencyAccount>)currentEditableAccountForExchangeOperation:(id<RTAExchangeOperation>)operation {
    return _selectedAccountRow == RTAAccountRowExpense ? _exchangeOperation.expenseAccount : _exchangeOperation.replenishmentAccount;
}

#pragma mark - Private methods
- (void)configureView:(RTACurrencyAccountView *)view withCurrencyAccount:(id<RTACurrencyAccount>)currencyAccount {
    view.currencyLabel.text = currencyAccount.currency.code;
    NSString *fundString = [NSString stringWithFormat:@" %@%.2f", currencyAccount.currency.sign, currencyAccount.funds.doubleValue];
    view.fundLabel.text = [NSLocalizedString(@"You have", @"In context of \"You have $100\"") stringByAppendingString:fundString];
    view.fundLabel.textColor = UIColor.lightSteelBlue;
}

- (void)configureView:(RTACurrencyAccountView *)view withExpenseAccount:(id<RTACurrencyAccount>)expenseAccount {
    [self configureView:view withCurrencyAccount:expenseAccount];
    NSDecimalNumber *rate = [expenseAccount.currency rateByCurrency:self.exchangeOperation.replenishmentAccount.currency];
    view.rateLabel.text = [NSString stringWithFormat:@"%@1 = %@%@", expenseAccount.currency.sign, self.exchangeOperation.replenishmentAccount.currency.sign, [RTANumberFormatter.rateFormatter stringFromNumber:rate]];
    view.type = RTACurrencyAccountViewTypeExpense;
    if ([self.exchangeOperation.expenseAccount isEqual:expenseAccount]) {
        view.fundLabel.textColor = !self.exchangeOperation.hasInsufficientFundsValidationError ? UIColor.lightSteelBlue : UIColor.alizarinRed;
        view.inputNumberText = [RTANumberFormatter.expenseAmountFormatter stringFromNumber:_exchangeOperation.amountCharged];
    }
}

- (void)configureView:(RTACurrencyAccountView *)view withReplenishmentAccount:(id<RTACurrencyAccount>)replenishmentAccount {
    [self configureView:view withCurrencyAccount:replenishmentAccount];
    NSDecimalNumber *rate = [replenishmentAccount.currency rateByCurrency:self.exchangeOperation.expenseAccount.currency];
    view.rateLabel.text = [NSString stringWithFormat:@"%@1 = %@%@", replenishmentAccount.currency.sign, self.exchangeOperation.expenseAccount.currency.sign, [RTANumberFormatter.rateFormatter stringFromNumber:rate]];
    view.type = RTACurrencyAccountViewTypeReplenishment;
    if ([self.exchangeOperation.replenishmentAccount isEqual:replenishmentAccount]) {
        view.inputNumberText = [RTANumberFormatter.replenishmentAmountFormatter stringFromNumber:_exchangeOperation.amountOfReplenishment];
    }
}

- (void)setup {
    [RTARevolutService.sharedInstance start];
    RTACurrencyExchangeViewController __weak *wSelf = self;    
    [RTARevolutService.sharedInstance provideExchangeOperationWithCompletionHandler:^(id<RTAExchangeOperation>  _Nullable exchangeOperation, NSError * _Nullable error) {
        wSelf.exchangeOperation = exchangeOperation;
        wSelf.exchangeOperation.delegate = self;
        wSelf.error = error;
        wSelf.sections = (error ? @[@(RTAExchangeSectionInfo)] : @[@(RTAExchangeSectionAccounts)]).kvoMutableCopy;
        [wSelf setupSectionsObserving];
        if (self.isViewLoaded) {
            [wSelf.tableView reloadData];
            [RTABlockerController.sharedInstance hide];
        }
    }];
}

- (void)setupSectionsObserving {
    if (_token) {
        return;
    }
    RTACurrencyExchangeViewController __weak *wSelf = self;
    _token = [self.sections addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        RTACurrencyExchangeViewController *sSelf = wSelf;
        NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] integerValue];
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        switch (kind) {
            case NSKeyValueChangeInsertion:
                [sSelf.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSKeyValueChangeRemoval:
                [sSelf.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSKeyValueChangeReplacement:
                [sSelf.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
            default:
                break;
        }
        return YES;
    }];
}

- (void)reloadCurrancyAccountCell:(RTACurrencyAccountsCell *)cell {
    if (RTARevolutService.sharedInstance.currencyAccounts.count != cell.numberOfItems) {
        [cell reloadCarousel];
    } else {
        [cell reloadItemAtIndex:[self currentAccountIndexForRow:cell.tag]];
    }
}

- (NSInteger)currentAccountIndexForRow:(RTAAccountRow)row {
    id<RTACurrencyAccount> currentAccount = row == RTAAccountRowExpense ? _exchangeOperation.expenseAccount : _exchangeOperation.replenishmentAccount;
    return [RTARevolutService.sharedInstance.currencyAccounts indexOfObject:currentAccount];
}


- (void)updateExpense {
    RTACurrencyAccountsCell *cell = (RTACurrencyAccountsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:RTAAccountRowExpense
                                                                                                                        inSection:0]];
    if (cell) {
        [self configureView:cell.currentItemView withExpenseAccount:_exchangeOperation.expenseAccount];
    }
}

- (void)updateReplenishment {
    RTACurrencyAccountsCell *cell = (RTACurrencyAccountsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:RTAAccountRowReplenishment
                                                                                                                        inSection:0]];
    if (cell) {
        [self configureView:cell.currentItemView withReplenishmentAccount:_exchangeOperation.replenishmentAccount];
    }
}

- (nullable RTACurrencyAccountsCell *)selectedAccountsCell {
    return (RTACurrencyAccountsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedAccountRow
                                                                                               inSection:self.indexOfAccountsSection]];
}

- (NSUInteger)indexOfAccountsSection {
    return [_sections indexOfObject:@(RTAExchangeSectionAccounts)];
}

- (NSUInteger)indexOfInfoSection {
    return [_sections indexOfObject:@(RTAExchangeSectionInfo)];
}

- (void)setError:(nullable NSError *)error {
    if (![_error isEqual:error]) {
        _error = error;
        [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:YES];
    }
}

- (nullable UIBarButtonItem *)rightBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Exchange", nil) style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemDidTap:)];
    [item setTitleTextAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0],
                                    NSForegroundColorAttributeName: UIColor.whiteColor }
                        forState:UIControlStateNormal];
    return !_error ? item : nil;
}

- (void)barButtonItemDidTap:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    self.error = self.exchangeOperation.validationError;
    if (self.error) {
        self.sections[0] = @(RTAExchangeSectionInfo);
        return;
    }
    [RTABlockerController.sharedInstance show];
    RTACurrencyExchangeViewController __weak *wSelf = self;
    [RTARevolutService.sharedInstance executeExchangeOperation:_exchangeOperation
                                         withCompletionHandler:^(id<RTAExchangeOperation>  _Nullable completedOperation, NSError * _Nullable error) {
                                             RTACurrencyExchangeViewController *sSelf = wSelf;
                                             sSelf.exchangeOperation = completedOperation;
                                             sSelf.error = error;
                                             if (!error) {
                                                 [sSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:sSelf.indexOfAccountsSection]
                                                                withRowAnimation:UITableViewRowAnimationAutomatic];
                                             } else {
                                                 sSelf.sections[0] = @(RTAExchangeSectionInfo);
                                             }
                                             [RTABlockerController.sharedInstance hide];
                                         }];
}

@end

NS_ASSUME_NONNULL_END
