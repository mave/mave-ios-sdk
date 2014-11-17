//
//  MAVEReferralData.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/17/14.
//  Data tracked through the appstore
//
//

#import <UIKit/UIKit.h>

@interface MAVEReferralData : UIView

@property (weak, nonatomic) NSString *referringCode;
@property (weak, nonatomic) NSString *referringUserID;
@property (weak, nonatomic) NSString *referringUserFirstName;
@property (weak, nonatomic) NSString *referringUserLastName;

@end