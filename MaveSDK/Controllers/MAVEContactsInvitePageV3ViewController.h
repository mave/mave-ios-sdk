//
//  MAVEContactsInvitePageV3ViewController.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageV3Cell.h"
#import "MAVEInviteTableSectionHeaderView.h"
#import "MAVEContactsInvitePageDataManager.h"

@interface MAVEContactsInvitePageV3ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// Use an instance of the cell for calculating the height of rows.
@property (nonatomic, strong) MAVEContactsInvitePageV3Cell *sampleCell;
// Keep a reference to the suggestions section, because we put the loading dots in the section
// header when suggested invites are still loading
@property (nonatomic, strong) MAVEInviteTableSectionHeaderView *suggestionsSectionHeaderView;


@property (nonatomic, strong) MAVEContactsInvitePageDataManager *dataManager;

@end
