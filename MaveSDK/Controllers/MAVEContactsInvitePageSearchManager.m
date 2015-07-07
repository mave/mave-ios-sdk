//
//  MAVEContactsInvitePageSearchManager.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/28/15.
//
//

#import "MAVEContactsInvitePageSearchManager.h"
#import "MAVEABTableViewController.h"

@implementation MAVEContactsInvitePageSearchManager

- (instancetype)initWithDataManager:(MAVEContactsInvitePageDataManager *)dataManager mainTable:(UITableView *)mainTable andSearchTable:(UITableView *)searchTable {
    if (self = [super init]) {
        self.dataManager = dataManager;
        self.mainTable = mainTable;
        self.searchTable = searchTable;
        self.searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.useNewNumber = nil;
        self.didSendToNewNumber = NO;
        self.useNewEmail = nil;
    }
    return self;
}

#pragma mark - Text Field delegate search functionality
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newText length] > 0 && [[newText substringFromIndex:[newText length]-1] isEqualToString:@"\n"]) {
        [textField endEditing:YES];
        return NO;
    }
    if ([newText length] > 0) {
        self.searchTable.hidden = NO;
        self.mainTable.hidden = YES;
        [self searchContactsAndUpdateSearchTableWithTerm:newText];
    } else {
        self.searchTable.hidden = YES;
        self.mainTable.hidden = NO;
    }
    return YES;
}

- (void)searchContactsAndUpdateSearchTableWithTerm:(NSString *)searchTerm {
    self.useNewNumber = nil;
    self.didSendToNewNumber = NO;
    self.didSendToNewEmail = NO;
    NSArray *searchResults = [MAVEABTableViewController searchContacts:self.dataManager.allContacts withText:searchTerm];
    // if no search results, see if it's a new phone number or email that we should send to
    if ([searchResults count] == 0) {
        NSString *normalizedPhone = [MAVEABPerson normalizePhoneNumber:searchTerm];
        if (normalizedPhone) {
            self.useNewNumber = normalizedPhone;
            self.dataManager.searchTableData = @[];
            [self.searchTable reloadData];
            return;
        }
        BOOL isEmail = [MAVEABPerson looksLikeEmail:searchTerm];
        if (isEmail) {
            self.useNewEmail = searchTerm;
            self.dataManager.searchTableData = @[];
            [self.searchTable reloadData];
            return;
        }
    }
    self.dataManager.searchTableData = searchResults;
    [self.searchTable reloadData];
}

- (void)clearCurrentSearchInTextField:(UITextField *)textField {
    textField.text = @"";
    self.searchTable.hidden = YES;
    self.mainTable.hidden = NO;
    [self.mainTable reloadData];
}

@end
