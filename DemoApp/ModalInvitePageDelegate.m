//
//  ModalInvitePageDelegate.m
//  Mave
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import "ModalInvitePageDelegate.h"

@implementation ModalInvitePageDelegate

- (void)userDidSendInvites {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCancel {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
