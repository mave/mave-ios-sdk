//
//  MAVENativeSharePageView.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVECustomSharePageViewController.h"
#import "MAVEShareButtonsView.h"

@interface MAVECustomSharePageView : UIView

@property (nonatomic, weak) MAVECustomSharePageViewController *delegate;
@property (nonatomic, strong) UILabel *shareExplanationLabel;
@property (nonatomic, strong) MAVEShareButtonsView *shareIconsView;

- (instancetype)initWithDelegate:(MAVECustomSharePageViewController *)delegate;

@end
