//
//  MAVEContactsInvitePageV2ViewController.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2ViewController.h"
#import "MAVEContactsInvitePageV2TableHeaderView.h"
#import "MAVEContactsInvitePageV2TableViewCell2.h"

NSString * const MAVEContactsInvitePageV2CellIdentifier = @"personCell";

@implementation MAVEContactsInvitePageV2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helpers for accessing deeply nested objects
- (UITableView *)tableView {
    return self.wrapperView.tableView;
}
- (UITextView *)messageTextView {
    return self.wrapperView.aboveTableView.messageTextView;
}

- (void)loadView {
    self.navigationItem.title = @"Send SMS Separately";

    self.wrapperView = [[MAVEContactsInvitePageV2TableWrapperView alloc] init];

    // set self up as delegates and such
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.estimatedSectionHeaderHeight = 90;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerNib:[UINib nibWithNibName:@"MAVEContactsInvitePageV2Cell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MAVEContactsInvitePageV2CellIdentifier];

//    [self.tableView registerClass:[MAVEContactsInvitePageV2TableViewCell2 class]
//                       forCellReuseIdentifier:MAVEContactsInvitePageV2CellIdentifier];
    self.messageTextView.delegate = self;


    self.wrapperView.frame = CGRectMake(0, 64, 200, 200);

    self.view = self.wrapperView;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

//- (void)resizeTableHeaderView {
//    CGRect screenBounds = [UIScreen mainScreen].bounds;
//
//    CGFloat screenWidth = screenBounds.size.width;
//    CGSize headerBounds = CGSizeMake(screenWidth, CGFLOAT_MAX);
//    CGFloat headerViewHeight = [self.tableHeaderView sizeThatFits:headerBounds].height;
//    self.tableHeaderView.frame = CGRectMake(0, 0, screenWidth, headerViewHeight);
//}

#pragma mark - TextViewDelegate methods (for message field)
- (void)textViewDidChange:(UITextView *)textView {
    [self.wrapperView layoutSubviews];
}

#pragma mark - TableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV2CellIdentifier];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected");

    MAVEContactsInvitePageV2TableViewCell2 *cell = (MAVEContactsInvitePageV2TableViewCell2 *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.expandedContactInfoHeightConstraint.constant = 50;
    [cell layoutIfNeeded];
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
}

@end
