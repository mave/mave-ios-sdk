//
//  MAVEContactsInvitePageV2ViewController.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageV2TableWrapperView.h"

@interface MAVEContactsInvitePageV2ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) MAVEContactsInvitePageV2TableWrapperView *wrapperView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSDictionary *indexedContactsForSectionedDisplay;

@end