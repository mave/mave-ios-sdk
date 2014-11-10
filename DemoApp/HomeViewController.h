//
//  ViewController.h
//  DemoApp
//
//  Created by dannycosson on 10/10/14.
//
//

#import <UIKit/UIKit.h>
#import "MaveSDK.h"

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *defaultMessageCopy;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSchemes;

@property (weak, nonatomic) UIViewController *invitePageViewController;

- (IBAction)presentInvitePageAsModal:(id)sender;

@end

