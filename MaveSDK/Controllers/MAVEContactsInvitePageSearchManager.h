//
//  MAVEContactsInvitePageSearchManager.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/28/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageDataManager.h"

@interface MAVEContactsInvitePageSearchManager : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) MAVEContactsInvitePageDataManager *dataManager;

- (instancetype)initWithDataManager:(MAVEContactsInvitePageDataManager *)dataManager;

@end
