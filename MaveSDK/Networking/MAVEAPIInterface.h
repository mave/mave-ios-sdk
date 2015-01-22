//
//  MAVEAPIInterface.h
//  MaveSDK
//
//  A session-aware interface to api requests for our app, appends the device & user information
//  and authentication parameters that our API expects on every request.
//  Created by Danny Cosson on 1/2/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEHTTPStack.h"
#import "MAVEUserData.h"


extern NSString * const MAVERouteTrackSignup;
extern NSString * const MAVERouteTrackAppLaunch;
extern NSString * const MAVERouteTrackInvitePageOpen;
extern NSString * const MAVERouteTrackInvitePageSelectedContact;
extern NSString * const MAVERouteTrackShareActionClick;
extern NSString * const MAVERouteTrackShare;

extern NSString * const MAVERouteTrackContactsPrePermissionPromptView;
extern NSString * const MAVERouteTrackContactsPrePermissionGranted;
extern NSString * const MAVERouteTrackContactsPrePermissionDenied;
extern NSString * const MAVERouteTrackContactsPermissionPromptView;
extern NSString * const MAVERouteTrackContactsPermissionGranted;
extern NSString * const MAVERouteTrackContactsPermissionDenied;

extern NSString * const MAVEAPIParamPrePromptTemplateID;
extern NSString * const MAVEAPIParamInvitePageType;
extern NSString * const MAVEAPIParamContactSelectedFromList;
extern NSString * const MAVEAPIParamShareMedium;
extern NSString * const MAVEAPIParamShareToken;
extern NSString * const MAVEAPIParamShareAudience;



@interface MAVEAPIInterface : NSObject

@property (nonatomic, strong) MAVEHTTPStack *httpStack;

// User session info, pulled from MaveSDK singleton
- (NSString *)applicationID;
- (NSString *)applicationDeviceID;
- (MAVEUserData *)userData;

///
/// Specific event tracking requests
///

- (void)trackAppOpen;
- (void)trackSignup;
- (void)trackInvitePageOpenForPageType:(NSString *)invitePageType;
- (void)trackInvitePageSelectedContactFromList:(NSString *)listType;
- (void)trackShareActionClickWithShareType:(NSString *)shareType;
- (void)trackShareWithShareType:(NSString *)shareType
                     shareToken:(NSString *)shareToken
                       audience:(NSString *)audience;

///
/// Other individual requests
///
- (void)identifyUser;
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
                        userId:(NSString *)userId
      inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
               completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

///
/// GET requests
///
- (void)getReferringUser:(void (^)(MAVEUserData *userData))referringUserBlock;
- (void)getRemoteConfigurationWithCompletionBlock:(MAVEHTTPCompletionBlock)block;
- (void)getNewShareTokenWithCompletionBlock:(MAVEHTTPCompletionBlock)block;

///
/// Request Sending Helpers
///
// Add current user session info onto the request
- (void)addCustomUserHeadersToRequest:(NSMutableURLRequest *)request;

// Main request method we use against our API
- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodName:(NSString *)methodName
                                    params:(NSDictionary *)params
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

// Send a POST request to the given event url to track the event, ignoring response.
// If userData is not null, the user id will be included in the request data, plus any
// additional params passed in.
- (void)trackGenericUserEventWithRoute:(NSString *)relativeRoute
                      additionalParams:(NSDictionary *)params;



@end
