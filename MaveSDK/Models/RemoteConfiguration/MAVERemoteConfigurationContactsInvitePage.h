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

@interface MAVERemoteConfigurationContactsInvitePage : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) BOOL enabled;
@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *explanationCopy;
@property (nonatomic) BOOL suggestedInvitesEnabled;
@property (nonatomic, assign) MAVESMSInviteSendMethod smsInviteSendMethod;

+ (NSDictionary *)defaultJSONData;

@end
