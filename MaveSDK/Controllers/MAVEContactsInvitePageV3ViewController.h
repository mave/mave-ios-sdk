//
//  MAVEContactsInvitePageV3ViewController.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageV3Cell.h"

@interface MAVEContactsInvitePageV3ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// Use an instance of the cell for calculating the height of rows.
@property (nonatomic, strong) MAVEContactsInvitePageV3Cell *sampleCell;
@property (nonatomic, strong) NSArray *tableData;

@end
