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
#import "MAVEContactIdentifierBase.h"
#import "MAVEMerkleTree.h"
#import "MAVEPromise.h"


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

extern NSString * const MAVEAPIParamInvitePageType;
extern NSString * const MAVEAPIParamPrePromptTemplateID;
extern NSString * const MAVEAPIParamContactsPermissionStatus;
extern NSString * const MAVEAPIParamContactSelectedFromList;
extern NSString * const MAVEAPIParamShareMedium;
extern NSString * const MAVEAPIParamShareToken;
extern NSString * const MAVEAPIParamShareAudience;



@interface MAVEAPIInterface : NSObject

@property (nonatomic, strong) MAVEHTTPStack *httpStack;

- (instancetype)initWithBaseURL:(NSString *)baseURL;
- (void)setupLoggingOnInit;

// User session info, pulled from MaveSDK singleton
- (NSString *)applicationID;
- (NSString *)applicationDeviceID;
- (MAVEUserData *)userData;

///
/// Specific event tracking requests
///

- (void)trackAppOpen;
- (void)trackAppOpenFetchingReferringDataWithPromise:(MAVEPromise *)promise;
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
// Deprecated: previous send invites method
- (void)sendInvitesWithRecipientPhoneNumbers:(NSArray *)recipientPhones
                     recipientContactRecords:(NSArray *)recipientContacts
                                     message:(NSString *)messageText
                                      userId:(NSString *)userId
                    inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
                              wrapInviteLink:(BOOL)wrapInviteLink
                                  customData:(NSDictionary *)customData
                             completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

// Current send invites method, using the "selected" property of phone & email records
// attached to the MAVEABPerson recipients.
- (void)sendInvitesToRecipients:(NSArray *)recipients
                        smsCopy:(NSString *)smsCopy
                   senderUserID:(NSString *)senderUserID
       inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
                 wrapInviteLink:(BOOL)wrapInviteLink
                     customData:(NSDictionary *)customData
                completionBlock:(MAVEHTTPCompletionBlock)completionBlock;
- (void)sendInviteToAnonymousContactIdentifier:(MAVEContactIdentifierBase *)contactIdentifier
                                       smsCopy:(NSString *)smsCopy
                                  senderUserID:(NSString *)senderUserID
                      inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
                                wrapInviteLink:(BOOL)wrapInviteLink
                                    customData:(NSDictionary *)customData
                               completionBlock:(MAVEHTTPCompletionBlock)completionBlock;


- (void)sendContactsMerkleTree:(MAVEMerkleTree *)merkleTree;
- (void)sendContactsChangeset:(NSArray *)changeset
            isFullInitialSync:(BOOL)isFullInitialSync
            ownMerkleTreeRoot:(NSString *)ownMerkleTreeRoot
        returnClosestContacts:(BOOL)returnClosestContacts
              completionBlock:(void (^)(NSArray *closestContacts))closestContactsBlock;
- (void)markSuggestedInviteAsDismissedByUser:(uint64_t)hashedRecordID;

///
/// GET requests
///
- (void)getReferringData:(MAVEHTTPCompletionBlock)completionBlock;
- (void)getClosestContactsHashedRecordIDs:(void (^)(NSArray *closestContacts))closestContactsBlock;
- (void)getRemoteConfigurationWithCompletionBlock:(MAVEHTTPCompletionBlock)block;
- (void)newShareTokenWithDetails:(NSDictionary *)details completionBlock:(MAVEHTTPCompletionBlock)block;
- (void)getRemoteContactsMerkleTreeRootWithCompletionBlock:(MAVEHTTPCompletionBlock)block;
- (void)getRemoteContactsFullMerkleTreeWithCompletionBlock:(MAVEHTTPCompletionBlock)block;

///
/// Request Sending Helpers
///
// Add current user session info onto the request
- (void)addCustomUserHeadersToRequest:(NSMutableURLRequest *)request;
// Helper for adding arbitrary headers
- (void)addExtraHeaders:(NSDictionary *)extraHeaders toRequest:(NSMutableURLRequest *)request;

// Main request method we use against our API
- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodName:(NSString *)methodName
                                    params:(id)params
                              extraHeaders:(NSDictionary *)extraHeaders
                          gzipCompressBody:(BOOL)gzipCompressBody
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

// Send a POST request to the given event url to track the event, ignoring response.
// If userData is not null, the user id will be included in the request data, plus any
// additional params passed in.
- (void)trackGenericUserEventWithRoute:(NSString *)relativeRoute
                      additionalParams:(NSDictionary *)params
                       completionBlock:(MAVEHTTPCompletionBlock)completionBlock;



@end
