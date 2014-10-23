//
//  InvitePageWrapperForDrawer.m
//  GrowthKit
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import "InvitePageDelegate.h"
#import "MMDrawerBarButtonItem.h"

@implementation InvitePageDelegate

- (void)userDidCancel {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)userDidSendInvites {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (UIBarButtonItem *)cancelBarButtonItem {
    return [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(userDidCancel)];
}

@end
