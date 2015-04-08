//
//  MAVEContactsInvitePageV2ViewController.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2ViewController.h"
#import "MAVEContactsInvitePageV2TableHeaderView.h"

@interface MAVEContactsInvitePageV2ViewController ()

@end

@implementation MAVEContactsInvitePageV2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    self.navigationItem.title = @"Send SMS Separately";

    self.wrapperView = [[MAVEContactsInvitePageV2TableWrapperView alloc] init];
    self.wrapperView.aboveTableView.messageTextView.delegate = self;

    
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

@end
