//
//  MAVERemoteConfigurationInvitePage.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/9/15.
//
//

#import "MAVERemoteConfigurationInvitePageChoice.h"
#import "MAVERemoteConfiguration.h"

NSString * const MAVERemoteConfigKeyTemplate = @"template";
NSString * const MAVERemoteConfigKeyInvitePagePrimary = @"primary_page";
NSString * const MAVERemoteConfigKeyInvitePageFallback = @"fallback_page";

@implementation MAVERemoteConfigurationInvitePageChoice

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyTemplate];
        MAVEInvitePageType primaryPageType = [[self class] invitePageTypeFromJSONStringName:[template objectForKey:MAVERemoteConfigKeyInvitePagePrimary]];
        if (primaryPageType == MAVEInvitePageTypeNone) {
            primaryPageType = MAVEInvitePageTypeContactsInvitePage;
        }
        self.primaryPageType = primaryPageType;

        MAVEInvitePageType fallbackPageType = [[self class] invitePageTypeFromJSONStringName:[template objectForKey:MAVERemoteConfigKeyInvitePageFallback]];
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
    } else if ([pageType isEqualToString:@"contacts_invite_page_v2"]) {
        return MAVEInvitePageTypeContactsInvitePageV2;
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
        MAVERemoteConfigKeyTemplate: @{
            MAVERemoteConfigKeyInvitePagePrimary: @"contacts_invite_page",
            MAVERemoteConfigKeyInvitePageFallback: @"share_page",
        },
    };
}

@end
