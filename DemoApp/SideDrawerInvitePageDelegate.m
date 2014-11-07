//
//  InvitePageWrapperForDrawer.m
//  Mave
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import "SideDrawerInvitePageDelegate.h"
#import "MMDrawerBarButtonItem.h"

@implementation SideDrawerInvitePageDelegate

- (instancetype)initWithDrawerController:(MMDrawerController *)drawerController {
    if (self = [super init]) {
        self.mm_drawerController = drawerController;
    }
    return self;
}

- (void)userDidCancel {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)userDidSendInvites {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (UIBarButtonItem *)cancelBarButtonItem {
    return [[MMDrawerBarButtonItem alloc] initWithTarget:nil action:nil];
}

@end
