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

- (instancetype)initWithDataManager:(MAVEContactsInvitePageDataManager *)dataManager andSearchTable:(UITableView *)searchTable {
    if (self = [super init]) {
        self.dataManager = dataManager;
        self.searchTable = searchTable;
    }
    return self;
}

#pragma mark - Text Field delegate search functionality
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newText isEqualToString:@"\n"]) {
        [textField endEditing:YES];
        return NO;
    }
    if ([newText length] > 0) {
        self.searchTable.hidden = NO;
        [self searchContactsAndUpdateSearchTableWithTerm:newText];
    } else {
        self.searchTable.hidden = YES;
    }
    return YES;
}

- (void)searchContactsAndUpdateSearchTableWithTerm:(NSString *)searchTerm {
    self.dataManager.searchTableData = [MAVEABTableViewController searchContacts:self.dataManager.allContacts withText:searchTerm];
    [self.searchTable reloadData];
}

@end
