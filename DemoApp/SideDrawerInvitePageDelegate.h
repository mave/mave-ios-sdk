//
//  InvitePageDelegate.h
//  Mave
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import <Foundation/Foundation.h>
#import "Mave.h"
#import "MMDrawerController.h"

@interface SideDrawerInvitePageDelegate : NSObject <MAVEInvitePageDelegate>

@property (nonatomic, weak) MMDrawerController *mm_drawerController;

- (instancetype)initWithDrawerController:(MMDrawerController *)drawerController;

@end