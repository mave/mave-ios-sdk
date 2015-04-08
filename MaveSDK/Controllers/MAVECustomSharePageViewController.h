//
//  MAVEShareActions.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "MAVERemoteConfiguration.h"
#import "MAVESharer.h"
#import "MAVEShareButtonsView.h"

@interface MAVECustomSharePageViewController: UIViewController

@property (nonatomic, strong) MAVESharer *sharerObject;

@end
