//
//  ViewController.h
//  DemoApp
//
//  Created by dannycosson on 10/10/14.
//
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *defaultMessageCopy;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSchemes;

- (IBAction)presentInvitePageAsModal:(id)sender;

@end

