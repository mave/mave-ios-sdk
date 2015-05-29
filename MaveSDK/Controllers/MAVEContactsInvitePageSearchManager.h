//
//  MAVEContactsInvitePageSearchManager.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/28/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageDataManager.h"

@interface MAVEContactsInvitePageSearchManager : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) MAVEContactsInvitePageDataManager *dataManager;
@property (nonatomic, weak) UITableView *mainTable;
@property (nonatomic, weak) UITableView *searchTable;

- (instancetype)initWithDataManager:(MAVEContactsInvitePageDataManager *)dataManager mainTable:(UITableView *)mainTable andSearchTable:(UITableView *)searchTable;

- (void)searchContactsAndUpdateSearchTableWithTerm:(NSString *)searchTerm;
- (void)clearCurrentSearchInTextField:(UITextField *)textField;

@end
