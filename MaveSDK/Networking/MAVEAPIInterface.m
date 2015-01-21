//
//  MAVEAPIInterface.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/2/15.
//
//

#import "MAVEAPIInterface.h"
#import "MaveSDK.h"
#import "MAVEUserData.h"
#import "MAVEConstants.h"
#import "MAVEClientPropertyUtils.h"


NSString * const MAVERouteTrackSignup = @"/events/signup";
NSString * const MAVERouteTrackAppLaunch = @"/events/launch";
NSString * const MAVERouteTrackInvitePageOpen = @"/events/invite_page_open";
NSString * const MAVERouteTrackShareActionClick = @"/events/share_action_click";
NSString * const MAVERouteTrackShare = @"/events/share";

NSString * const MAVERouteTrackContactsPrePermissionPromptView = @"/events/contacts_pre_permission_prompt_view";
NSString * const MAVERouteTrackContactsPrePermissionGranted = @"/events/contacts_pre_permission_granted";
NSString * const MAVERouteTrackContactsPrePermissionDenied = @"/events/contacts_pre_permission_denied";
NSString * const MAVERouteTrackContactsPermissionPromptView = @"/events/contacts_permission_prompt_view";
NSString * const MAVERouteTrackContactsPermissionGranted = @"/events/contacts_permission_granted";
NSString * const MAVERouteTrackContactsPermissionDenied = @"/events/contacts_permission_denied";

NSString * const MAVEAPIParamPrePromptTemplateID = @"contacts_pre_permission_prompt_template_id";
NSString * const MAVEAPIParamInvitePageType = @"invite_page_type";
NSString * const MAVEAPIParamShareMedium = @"medium";
NSString * const MAVEAPIParamShareToken = @"share_token";
NSString * const MAVEAPIParamShareAudience = @"audience";

NSString * const MAVEAPIHeaderContextPropertiesInviteContext = @"invite_context";


@implementation MAVEAPIInterface

- (instancetype)init {
    if (self = [super init]) {
        NSString *baseURL = [MAVEAPIBaseURL stringByAppendingString:MAVEAPIVersion];
        self.httpStack = [[MAVEHTTPStack alloc] initWithAPIBaseURL:baseURL];
        MAVEInfoLog(@"Initialized on domain: %@", baseURL);
    }
    return self;
}

- (NSString *)applicationID {
    return [MaveSDK sharedInstance].appId;
}

- (NSString *)applicationDeviceID {
    return [MaveSDK sharedInstance].appDeviceID;
}

- (MAVEUserData *)userData {
    return [MaveSDK sharedInstance].userData;
}

///
/// Specific Tracking Events
///
- (void)trackAppOpen {
    [self trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch
                        additionalParams:nil];
}

- (void)trackSignup {
    [self trackGenericUserEventWithRoute:MAVERouteTrackSignup additionalParams:nil];
}

- (void)trackInvitePageOpenForPageType:(NSString *)invitePageType {
    if ([invitePageType length] == 0) {
        invitePageType = @"unknown";
    }
    NSDictionary *params = @{MAVEAPIParamInvitePageType: invitePageType};
    [self trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                        additionalParams:params];
}

- (void)trackShareActionClickWithShareType:(NSString *)shareType {
    if ([shareType length] == 0) {
        shareType = @"unknown";
    }
    [self trackGenericUserEventWithRoute:MAVERouteTrackShareActionClick
                        additionalParams:@{MAVEAPIParamShareMedium: shareType}];
}

- (void)trackShareWithShareType:(NSString *)shareType
                     shareToken:(NSString *)shareToken
                       audience:(NSString *)audience {
    if ([shareType length] == 0) {
        shareType = @"unknown";
    }
    if ([shareToken length] == 0) {
        shareToken = @"";
    }
    if ([audience length] == 0) {
        audience = @"unknown";
    }
    NSDictionary *params = @{MAVEAPIParamShareMedium: shareType,
                             MAVEAPIParamShareToken: shareToken,
                             MAVEAPIParamShareAudience: audience};
    [self trackGenericUserEventWithRoute:MAVERouteTrackShare additionalParams:params];
}

///
/// Other remote calls
///
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
                        userId:(NSString *)userId
      inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
               completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    NSString *invitesRoute = @"/invites/sms";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:persons forKey:@"recipients"];
    [params setObject:messageText forKey:@"sms_copy"];
    [params setObject:userId forKey:@"sender_user_id"];
    if ([inviteLinkDestinationURL length] > 0) {
        [params setObject:inviteLinkDestinationURL forKey:@"link_destination"];
    }
    
    [self sendIdentifiedJSONRequestWithRoute:invitesRoute
                                  methodName:@"POST"
                                      params:params
                             completionBlock:completionBlock];
}

- (void)identifyUser {
    NSString *launchRoute = @"/users";
    NSDictionary *params = [self.userData toDictionary];
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodName:@"PUT"
                                      params:params
                             completionBlock:nil];
}



//
// GET Requests
// We generally want to pre-fetch them so that when we actually want to access
// the data it's already here and there's no latency.
- (void)getReferringUser:(void (^)(MAVEUserData *userData))referringUserBlock {
    NSString *launchRoute = @"/referring_user";
    
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodName:@"GET"
                                      params:nil
                             completionBlock:^(NSError *error, NSDictionary *responseData) {
                                 MAVEUserData *userData;
                                 if (error || [responseData count] == 0) {
                                     userData = nil;
                                 } else {
                                     userData = [[MAVEUserData alloc] initWithDictionary:responseData];
                                 }
                                 referringUserBlock(userData);
                             }];
}

- (void)getRemoteConfigurationWithCompletionBlock:(MAVEHTTPCompletionBlock)block {
    NSString *route = @"/remote_configuration/ios";
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                             completionBlock:block];
}

- (void)getNewShareTokenWithCompletionBlock:(MAVEHTTPCompletionBlock)block {
    NSString *route = @"/remote_configuration/universal/share_token";
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                             completionBlock:block];
}


///
/// Request Sending Helpers
///
- (void)addCustomUserHeadersToRequest:(NSMutableURLRequest *)request {
    if (!request) {
        return;
    }
    [request setValue:self.applicationID forHTTPHeaderField:@"X-Application-Id"];
    [request setValue:self.applicationDeviceID forHTTPHeaderField:@"X-App-Device-Id"];
    NSString *userAgent = [MAVEClientPropertyUtils userAgentDeviceString];
    NSString *screenSize = [MAVEClientPropertyUtils formattedScreenSize];
    NSString *clientProperties = [MAVEClientPropertyUtils encodedAutomaticClientProperties];
    NSString *contextProperties = [MAVEClientPropertyUtils encodedContextProperties];

    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:screenSize forHTTPHeaderField:@"X-Device-Screen-Dimensions"];
    [request setValue:clientProperties forHTTPHeaderField:@"X-Client-Properties"];
    [request setValue:contextProperties forHTTPHeaderField:@"X-Context-Properties"];
}

- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodName:(NSString *)methodName
                                    params:(NSDictionary *)params
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    NSError *requestCreationError;
    NSMutableURLRequest *request = [self.httpStack prepareJSONRequestWithRoute:relativeURL
                                                                    methodName:methodName
                                                                        params:params
                                                              preparationError:&requestCreationError];
    if (requestCreationError) {
        completionBlock(requestCreationError, nil);
    }
    
    [self addCustomUserHeadersToRequest:request];
    
    [self.httpStack sendPreparedRequest:request completionBlock:completionBlock];
}

- (void)trackGenericUserEventWithRoute:(NSString *)relativeRoute
                      additionalParams:(NSDictionary *)params {
    NSMutableDictionary *fullParams = [[NSMutableDictionary alloc] init];
    MAVEUserData *userData = [MaveSDK sharedInstance].userData;
    if (userData.userID) {
        [fullParams setObject:userData.userID forKey:MAVEUserDataKeyUserID];
    }
    for (NSString *key in params) {
        [fullParams setObject:[params objectForKey:key] forKey:key];
    }
    
    [self sendIdentifiedJSONRequestWithRoute:relativeRoute
                                  methodName:@"POST"
                                      params:fullParams
                             completionBlock:nil];
}

@end
