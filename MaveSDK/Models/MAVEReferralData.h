//
//  MAVEReferralData.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/17/14.
//  Data tracked through the appstore
//
//  NOT USED YET, we're currently just using a different instance of MAVEUserData for the referral user
//

#import <UIKit/UIKit.h>

@interface MAVEReferralData : UIView

@property (weak, nonatomic) NSString *referringCode;
@property (weak, nonatomic) NSString *referringUserID;
@property (weak, nonatomic) NSString *referringUserFirstName;
@property (weak, nonatomic) NSString *referringUserLastName;

@end