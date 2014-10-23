//
//  ModalInvitePageDelegate.m
//  GrowthKit
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import "ModalInvitePageDelegate.h"

@implementation ModalInvitePageDelegate

- (void)userDidSendInvites {
    
}

- (void)userDidCancel {
    NSLog(@"called my modal delegate");
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
