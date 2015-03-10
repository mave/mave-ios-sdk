//
//  MAVERemoteConfigurationInvitePage.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/9/15.
//
//

#import "MAVERemoteConfigurationInvitePage.h"
#import "MAVERemoteConfiguration.h"

NSString * const MAVERemoteConfigKeyInvitePagePrimary = @"primary_page";
NSString * const MAVERemoteConfigKeyInvitePageFallback = @"fallback_page";

@implementation MAVERemoteConfigurationInvitePage

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        MAVEInvitePageType primaryPageType = [[self class] invitePageTypeFromJSONStringName:[data objectForKey:MAVERemoteConfigKeyInvitePagePrimary]];
        if (primaryPageType == MAVEInvitePageTypeNone) {
            primaryPageType = MAVEInvitePageTypeContactsInvitePage;
        }
        self.primaryPageType = primaryPageType;

        MAVEInvitePageType fallbackPageType = [[self class] invitePageTypeFromJSONStringName:[data objectForKey:MAVERemoteConfigKeyInvitePageFallback]];
        if (fallbackPageType == MAVEInvitePageTypeNone) {
            fallbackPageType = MAVEInvitePageTypeSharePage;
        }
        self.fallbackPageType = fallbackPageType;
    }
    return self;
}

+ (MAVEInvitePageType)invitePageTypeFromJSONStringName:(NSString *)pageType {
    if ([pageType isEqualToString:@"contacts_invite_page"]) {
        return MAVEInvitePageTypeContactsInvitePage;
    } else if ([pageType isEqualToString:@"share_page"]) {
        return MAVEInvitePageTypeSharePage;
    } else if ([pageType isEqualToString:@"client_sms"]) {
        return MAVEInvitePageTypeClientSMS;
    } else {
        return MAVEInvitePageTypeNone;
    }
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyInvitePagePrimary: @"contacts_invite_page",
        MAVERemoteConfigKeyInvitePageFallback: @"share_page",
    };
}

@end
