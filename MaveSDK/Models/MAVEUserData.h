//
//  MAVEUserData.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import <Foundation/Foundation.h>

extern NSString * const MAVEUserDataKeyUserID;

@interface MAVEUserData : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *promoCode;

// Internal flag, for use with anonymous users
@property (nonatomic, assign) BOOL isSetAutomaticallyFromDevice;

// Explicitly set the link that will be used in invites sent by this user.
// Optional, without this being set invites will to the relevant app-store
// or generic web signup page, depending on the platform the person who
// clicks the link is on (e.g. click on ios -> ios app store).
@property (strong, nonatomic) NSString *inviteLinkDestinationURL;
// Whether Mave should wrap the invite link in a deep link, which adds
// analytics and redirects to the appropriate place based on device.
// Defaults to YES, but you can set to NO if using your own deep linking tool
@property (nonatomic, assign) BOOL wrapInviteLink;

// customData is a freeform dictionary that you can use to
// pass through any data you want to retrieve once the invited user opens
// your app from this invite link. It will be available as the `customData`
// property on the MAVEReferringData object. It is sent over our API as JSON
// data so the object you pass in here must be JSON serializable - i.e.
// NSJSONSerializiation `isValidJSONObject:` returns true.
@property (nonatomic, strong) NSDictionary *customData;


- (instancetype)initWithUserID:(NSString *)userID
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName;

- (instancetype)initWithUserID:(NSString *)userID
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName
                         email:(NSString *)email
                         phone:(NSString *)phone;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

// Convert to a dictionary, e.g. to be serialized as JSON for an API request
- (NSDictionary *)toDictionary;
// Serializes only the userID field to a dictionary
- (NSDictionary *)toDictionaryIDOnly;

// Convenience Methods
- (NSString *)fullName;

// Dealing with anonymous users
- (instancetype)initAutomaticallyFromDeviceName;
// Helper to decide whether this user can send a server-side SMS.
// Needs an ID and at least first name, and if the name was set
// from the device name do some checks that it's not obviously
// not a person's name.
- (BOOL)isUserInfoOkToSendServerSideSMS;

@end
