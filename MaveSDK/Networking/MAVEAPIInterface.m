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
#import "MAVEABUtils.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVECompressionUtils.h"


NSString * const MAVERouteTrackSignup = @"/events/signup";
NSString * const MAVERouteTrackAppLaunch = @"/events/launch";
NSString * const MAVERouteTrackInvitePageOpen = @"/events/invite_page_open";
NSString * const MAVERouteTrackInvitePageSelectedContact = @"/events/selected_contact_on_invite_page";
NSString * const MAVERouteTrackShareActionClick = @"/events/share_action_click";
NSString * const MAVERouteTrackShare = @"/events/share";

NSString * const MAVERouteTrackContactsPrePermissionPromptView = @"/events/contacts_pre_permission_prompt_view";
NSString * const MAVERouteTrackContactsPrePermissionGranted = @"/events/contacts_pre_permission_granted";
NSString * const MAVERouteTrackContactsPrePermissionDenied = @"/events/contacts_pre_permission_denied";
NSString * const MAVERouteTrackContactsPermissionPromptView = @"/events/contacts_permission_prompt_view";
NSString * const MAVERouteTrackContactsPermissionGranted = @"/events/contacts_permission_granted";
NSString * const MAVERouteTrackContactsPermissionDenied = @"/events/contacts_permission_denied";

NSString * const MAVEAPIParamInvitePageType = @"invite_page_type";
NSString * const MAVEAPIParamPrePromptTemplateID = @"contacts_pre_permission_prompt_template_id";
NSString * const MAVEAPIParamContactsPermissionStatus = @"contacts_permission_status";
NSString * const MAVEAPIParamContactSelectedFromList = @"from_list";
NSString * const MAVEAPIParamShareMedium = @"medium";
NSString * const MAVEAPIParamShareToken = @"share_token";
NSString * const MAVEAPIParamShareAudience = @"audience";


NSString * const MAVEAPIHeaderContextPropertiesInviteContext = @"invite_context";


@implementation MAVEAPIInterface

- (instancetype)initWithBaseURL:(NSString *)baseURL {
    if (self = [super init]) {
        self.httpStack = [[MAVEHTTPStack alloc] initWithAPIBaseURL:baseURL];
        [self setupLoggingOnInit];
    }
    return self;
}

- (void)setupLoggingOnInit {
    NSString *logMessage = [NSString stringWithFormat:@"Initialized on domain: %@", self.httpStack.baseURL];
    self.httpStack.requestLoggingBlock(logMessage);
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
    [self trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch additionalParams:nil completionBlock:nil];
}

- (void)trackAppOpenFetchingReferringDataWithPromise:(MAVEPromise *)promise {
    NSDictionary *params = @{@"return_referring_data": @YES};
    [self trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch additionalParams:params completionBlock:^(NSError *error, NSDictionary *responseData) {
        MAVEDebugLog(@"Referring data returned on launch: %@", responseData);
        NSDictionary *referringData = [responseData objectForKey:@"referring_data"];
        if (referringData && (id)referringData != [NSNull null]) {
            [promise fulfillPromise:(NSValue *)referringData];
        };
    }];
}

- (void)trackSignup {
    [self trackGenericUserEventWithRoute:MAVERouteTrackSignup additionalParams:nil completionBlock:nil];
}

- (void)trackInvitePageOpenForPageType:(NSString *)invitePageType {
    if ([invitePageType length] == 0) {
        invitePageType = @"unknown";
    }
    NSDictionary *params = @{MAVEAPIParamInvitePageType: invitePageType,
                             MAVEAPIParamContactsPermissionStatus: [MAVEABUtils addressBookPermissionStatus],
                             };
    [self trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                        additionalParams:params completionBlock:nil];
}

- (void)trackInvitePageSelectedContactFromList:(NSString *)listType {
    if ([listType length] == 0) {
        listType = @"unknown";
    }
    NSDictionary *params = @{MAVEAPIParamContactSelectedFromList: listType};
    [self trackGenericUserEventWithRoute:MAVERouteTrackInvitePageSelectedContact
                        additionalParams:params completionBlock:nil];
}

- (void)trackShareActionClickWithShareType:(NSString *)shareType {
    if ([shareType length] == 0) {
        shareType = @"unknown";
    }
    [self trackGenericUserEventWithRoute:MAVERouteTrackShareActionClick
                        additionalParams:@{MAVEAPIParamShareMedium: shareType} completionBlock:nil];
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
    [self trackGenericUserEventWithRoute:MAVERouteTrackShare additionalParams:params completionBlock:nil];
}

///
/// Other remote calls
///
- (void)sendInvitesWithRecipientPhoneNumbers:(NSArray *)recipientPhones
                     recipientContactRecords:(NSArray *)recipientContacts
                                     message:(NSString *)messageText
                                      userId:(NSString *)userId
                    inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
                              wrapInviteLink:(BOOL)wrapInviteLink
                                  customData:(NSDictionary *)customData
                             completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    NSString *invitesRoute = @"/invites/sms";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:recipientPhones forKey:@"recipient_phone_numbers"];

    if (recipientContacts && (id)recipientContacts != [NSNull null]) {
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:[recipientContacts count]];
        for (MAVEABPerson *contact in recipientContacts) {
            [tmp addObject:[contact toJSONDictionary]];
        }
        [params setObject:[NSArray arrayWithArray:tmp] forKey:@"recipient_contact_records"];
    }

    [params setObject:@(wrapInviteLink) forKey:@"wrap_invite_link"];

    [params setObject:messageText forKey:@"sms_copy"];
    [params setObject:userId forKey:@"sender_user_id"];
    if ([inviteLinkDestinationURL length] > 0) {
        [params setObject:inviteLinkDestinationURL forKey:@"link_destination"];
    }
    if ([customData count] > 0) {
        [params setObject:customData forKey:@"custom_data"];
    }
    
    [self sendIdentifiedJSONRequestWithRoute:invitesRoute
                                  methodName:@"POST"
                                      params:params
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:completionBlock];
}

- (void)identifyUser {
    NSString *launchRoute = @"/users";
    NSDictionary *params = [self.userData toDictionary];
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodName:@"PUT"
                                      params:params
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:nil];
}

- (void)sendContactsMerkleTree:(MAVEMerkleTree *)merkleTree {
    NSString *route = @"/me/contacts/merkle_tree/full";
    NSDictionary *params = [merkleTree serializable];
    if (!params) {
        MAVEErrorLog(@"Error serializing merkle tree, not sending contacts to server");
        return;
    }
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"PUT"
                                      params:params
                                extraHeaders:nil
                            gzipCompressBody:YES
                             completionBlock:nil];
}

- (void)sendContactsChangeset:(NSArray *)changeset
            isFullInitialSync:(BOOL)isFullInitialSync
            ownMerkleTreeRoot:(NSString *)ownMerkleTreeRoot
        returnClosestContacts:(BOOL)returnClosestContacts
              completionBlock:(void (^)(NSArray *closestContacts))closestContactsBlock {
    NSString *route = @"/me/contacts/sync_changesets";
    NSDictionary *params = @{@"changeset_list": changeset,
                             @"is_full_initial_sync": @(isFullInitialSync),
                             @"own_merkle_tree_root": ownMerkleTreeRoot,
                             @"return_closest_contacts": @(returnClosestContacts)};
    [self sendIdentifiedJSONRequestWithRoute:route methodName:@"POST" params:params extraHeaders:nil gzipCompressBody:YES completionBlock:^(NSError *error, NSDictionary *responseData) {
        NSArray *returnVal;
        if (returnClosestContacts && !error) {
            returnVal = [responseData objectForKey:@"closest_contacts"];
            if (!returnVal || (id)returnVal == [NSNull null]) {
                returnVal = @[];
            }
        } else {
            returnVal = @[];
        }
        closestContactsBlock(returnVal);
    }];
}


//
// GET Requests
// We generally want to pre-fetch them so that when we actually want to access
// the data it's already here and there's no latency.
- (void)getReferringData:(MAVEHTTPCompletionBlock)completionBlock {
    NSString *route = @"/referring_data";

    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:completionBlock];
}

- (void)getClosestContactsHashedRecordIDs:(void (^)(NSArray *))closestContactsBlock {
    NSString *route = @"/me/contacts/closest";
    NSArray *emptyValue = @[];
    [self sendIdentifiedJSONRequestWithRoute:route methodName:@"GET" params:nil extraHeaders:nil gzipCompressBody:NO completionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error) {
            closestContactsBlock(emptyValue);
        } else {
            NSArray *val = [responseData objectForKey:@"closest_contacts"];
            if (!val) {
                val = emptyValue;
            }
            closestContactsBlock(val);
        }
    }];
}

- (void)getRemoteConfigurationWithCompletionBlock:(MAVEHTTPCompletionBlock)block {
    NSString *route = @"/remote_configuration/ios";
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:block];
}

- (void)getNewShareTokenWithCompletionBlock:(MAVEHTTPCompletionBlock)block {
    NSString *route = @"/remote_configuration/universal/share_token";
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:block];
}

- (void)getRemoteContactsMerkleTreeRootWithCompletionBlock:(MAVEHTTPCompletionBlock)block {
    NSString *route = @"/me/contacts/merkle_tree/root";
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:block];
}

- (void)getRemoteContactsFullMerkleTreeWithCompletionBlock:(MAVEHTTPCompletionBlock)block {
    NSString *route = @"/me/contacts/merkle_tree/full";
    [self sendIdentifiedJSONRequestWithRoute:route
                                  methodName:@"GET"
                                      params:nil
                                extraHeaders:nil
                            gzipCompressBody:NO
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
- (void)addExtraHeaders:(NSDictionary *)extraHeaders toRequest:(NSMutableURLRequest *)request {
    for (NSString *key in extraHeaders) {
        [request setValue:[extraHeaders valueForKey:key] forHTTPHeaderField:key];
    }
}

- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodName:(NSString *)methodName
                                    params:(id)params
                              extraHeaders:(NSDictionary *)extraHeaders
                          gzipCompressBody:(BOOL)gzipCompressBody
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    MAVEHTTPRequestContentEncoding contentEncoding = gzipCompressBody ? MAVEHTTPRequestContentEncodingGzip : MAVEHTTPRequestContentEncodingDefault;
    NSError *requestCreationError;
    NSMutableURLRequest *request = [self.httpStack prepareJSONRequestWithRoute:relativeURL
                                                                    methodName:methodName
                                                                        params:params
                                                               contentEncoding:contentEncoding
                                                              preparationError:&requestCreationError];
    if (requestCreationError) {
        if (completionBlock) {
            completionBlock(requestCreationError, nil);
        }
        return;
    }

    [self addCustomUserHeadersToRequest:request];
    [self addExtraHeaders:extraHeaders toRequest:request];
    [self.httpStack sendPreparedRequest:request completionBlock:completionBlock];
}

- (void)trackGenericUserEventWithRoute:(NSString *)relativeRoute
                      additionalParams:(NSDictionary *)params
                       completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    NSMutableDictionary *fullParams = [[NSMutableDictionary alloc] init];
    MAVEUserData *userData = [self userData];
    if (userData.userID) {
        [fullParams setObject:userData.userID forKey:MAVEUserDataKeyUserID];
    }
    for (NSString *key in params) {
        [fullParams setObject:[params objectForKey:key] forKey:key];
    }
    
    [self sendIdentifiedJSONRequestWithRoute:relativeRoute
                                  methodName:@"POST"
                                      params:fullParams
                                extraHeaders:nil
                            gzipCompressBody:NO
                             completionBlock:completionBlock];
}

@end
