//
//  InvitePageDelegate.h
//  GrowthKit
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import <Foundation/Foundation.h>
#import "GrowthKit.h"
#import "MMDrawerController.h"

@interface InvitePageDelegate : NSObject <GRKInvitePageDelegate>

@property (nonatomic, weak) MMDrawerController *mm_drawerController;

@end