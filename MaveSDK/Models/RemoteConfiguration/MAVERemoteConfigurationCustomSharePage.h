//
//  MAVERemoteConfigurationCustomSharePage.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/13/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"

@interface MAVERemoteConfigurationCustomSharePage : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) BOOL enabled;
@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, copy) NSString *explanationCopyTemplate;
@property (nonatomic, copy) NSString *inviteLinkBaseURL;
@property (nonatomic, assign) BOOL includeClientSMS;
@property (nonatomic, assign) BOOL includeClientEmail;
@property (nonatomic, assign) BOOL includeNativeFacebook;
@property (nonatomic, assign) BOOL includeNativeTwitter;
@property (nonatomic, assign) BOOL includeClipboard;
- (NSString *)explanationCopy;

+ (NSDictionary *)defaultJSONData;

@end
