//
//  MAVENativeSharePageView.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVECustomSharePageViewController.h"
#import "MAVEShareIconsView.h"

@interface MAVECustomSharePageView : UIView

@property (nonatomic, weak) MAVECustomSharePageViewController *delegate;
@property (nonatomic, strong) UILabel *shareExplanationLabel;
@property (nonatomic, strong) MAVEShareIconsView *shareIconsView;

- (instancetype)initWithDelegate:(MAVECustomSharePageViewController *)delegate;

@end
