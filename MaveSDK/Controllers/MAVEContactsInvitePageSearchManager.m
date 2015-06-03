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
    }
    return self;
}

#pragma mark - Text Field delegate search functionality
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newText length] > 0 && [[newText substringFromIndex:[newText length]-1] isEqualToString:@"\n"]) {
        MAVEABPerson *topResult = nil;
        if ([self.dataManager.searchTableData count] > 0) {
            for (MAVEABPerson *_person in self.dataManager.searchTableData) {
                if (_person.selected) {
                    topResult = _person;
                    break;
                }
            }
            if (!topResult) {
                topResult = [self.dataManager.searchTableData objectAtIndex:0];
            }
        }
        [textField endEditing:YES];
        [self clearCurrentSearchInTextField:textField];
        if (topResult) {
            NSIndexPath *path = [self.dataManager indexPathOfFirstOccuranceInMainTableOfPerson:topResult];
            [self.mainTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
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
    self.dataManager.searchTableData = [MAVEABTableViewController searchContacts:self.dataManager.allContacts withText:searchTerm];
    [self.searchTable reloadData];
}

- (void)clearCurrentSearchInTextField:(UITextField *)textField {
    textField.text = @"";
    self.searchTable.hidden = YES;
    self.mainTable.hidden = NO;
    [self.mainTable reloadData];
}

@end
