//
//  MAVEContactsInvitePageV2TableWrapperView.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2TableWrapperView.h"

@implementation MAVEContactsInvitePageV2TableWrapperView

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    // bg color so partly opaque stuff looks neutral, this view's content shouldn't be visible anywhere
    self.backgroundColor = [UIColor whiteColor];
    self.aboveTableView = [[MAVEContactsInvitePageV2AboveTableView alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.hidden = NO;
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.searchTableView.hidden = YES;
    [self addSubview:self.aboveTableView];
    [self addSubview:self.tableView];
    [self addSubview:self.searchTableView];
}

- (void)layoutSubviews {
    CGSize fullSize = self.frame.size;
    CGSize aboveTableSize = [self.aboveTableView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.aboveTableView.frame = CGRectMake(0, 0, fullSize.width, aboveTableSize.height);
    CGRect tableViewFrame = CGRectMake(0,
                                       aboveTableSize.height,
                                       fullSize.width,
                                       fullSize.height - aboveTableSize.height);
    self.tableView.frame = tableViewFrame;
    self.searchTableView.frame = tableViewFrame;
}

@end
