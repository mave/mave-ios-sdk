//
//  MAVEContactsInvitePageV2ViewController.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"
#import "MAVEContactsInvitePageV2TableWrapperView.h"
#import "MAVEInviteTableSectionHeaderView.h"

@protocol MAVEContactsWithSuggestionsTable <NSObject>

- (void)updateTableData:(NSDictionary *)tableData;
- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites;

@end

@interface MAVEContactsInvitePageV2ViewController : UIViewController <UITableViewDataSource, MAVEContactsWithSuggestionsTable, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MAVEContactsInvitePageV2TableWrapperView *wrapperView;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, strong) NSDictionary *tableData;
@property (nonatomic, strong) NSArray *searchTableData;
- (MAVEABPerson *)tableView:(UITableView *)tableView personForRowAtIndexPath:(NSIndexPath *)indexPath;

// Helpers for accessing nested objects
- (UITableView *)tableView;
- (UITextView *)messageTextView;

@end