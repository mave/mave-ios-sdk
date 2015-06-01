//
//  MAVERemoteConfigurationInvitePage.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

typedef NS_ENUM(NSInteger, MAVEInvitePageType) {
    MAVEInvitePageTypeNone,
    MAVEInvitePageTypeContactsInvitePage,
    MAVEInvitePageTypeContactsInvitePageV2,
    MAVEInvitePageTypeContactsInvitePageV3,
    MAVEInvitePageTypeSharePage,
    MAVEInvitePageTypeClientSMS,
};


@interface MAVERemoteConfigurationInvitePageChoice : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, assign) MAVEInvitePageType primaryPageType;
@property (nonatomic, assign) MAVEInvitePageType fallbackPageType;

+ (MAVEInvitePageType)invitePageTypeFromJSONStringName:(NSString *)pageType;
+ (NSDictionary *)defaultJSONData;

@end
