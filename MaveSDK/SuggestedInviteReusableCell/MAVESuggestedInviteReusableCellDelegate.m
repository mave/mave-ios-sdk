//
//  MAVESuggestedInviteReusableCellDelegate.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import "MAVESuggestedInviteReusableCellDelegate.h"
#import "MaveSDK.h"

@implementation MAVESuggestedInviteReusableCellDelegate

- (instancetype)initForTableView:(UITableView *)tableView startingIndexPath:(NSIndexPath *)startingIndexPath numberOfRows:(NSInteger)numberOfRows {
    if (self = [super init]) {
        self.tableView = tableView;
        self.startingIndexPath = startingIndexPath;
        self.numberOfRows = numberOfRows;
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    
}

@end
