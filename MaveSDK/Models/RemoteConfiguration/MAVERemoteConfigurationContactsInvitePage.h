//
//  MAVERemoteConfigurationContactsInvitePage.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/10/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

typedef NS_ENUM(NSInteger, MAVESMSInviteSendMethod) {
    MAVESMSInviteSendMethodServerSide,
    MAVESMSInviteSendMethodClientSideGroup
};

typedef NS_ENUM(NSInteger, MAVEReusableSuggestedInviteCellSendIcon) {
    MAVEReusableSuggestedInviteCellSendIconAirplane,
    MAVEReusableSuggestedInviteCellSendIconPersonPlus,
};

@interface MAVERemoteConfigurationContactsInvitePage : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) BOOL enabled;
@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *explanationCopyTemplate;
- (NSString *)explanationCopy;
@property (nonatomic, assign) BOOL shareButtonsEnabled;
@property (nonatomic, assign) BOOL suggestedInvitesEnabled;
@property (nonatomic, assign) BOOL selectAllEnabled;
@property (nonatomic, assign) MAVESMSInviteSendMethod smsInviteSendMethod;
@property (nonatomic, assign) MAVEReusableSuggestedInviteCellSendIcon reusableSuggestedInviteCellSendIcon;

+ (NSDictionary *)defaultJSONData;

@end
