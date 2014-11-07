//
//  InvitePageDelegate.h
//  MaveSDK
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import <Foundation/Foundation.h>
#import "MaveSDK.h"
#import "MMDrawerController.h"

@interface SideDrawerInvitePageDelegate : NSObject <MAVEInvitePageDelegate>

@property (nonatomic, weak) MMDrawerController *mm_drawerController;

- (instancetype)initWithDrawerController:(MMDrawerController *)drawerController;

@end