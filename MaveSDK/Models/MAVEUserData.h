//
//  MAVEUserData.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import <Foundation/Foundation.h>

#define MAVEUserDataKeyUserID @"user_id"

@interface MAVEUserData : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phone;

// Internal flag, for use with anonymous users
@property (nonatomic) BOOL isSetAutomaticallyFromDevice;

// Essentially a referral code for web & mobile web signup flows,
// if this (optional) URL is set invite links sent by this user
// redirect here instead of app store or a non-attributed signup page
@property (strong, nonatomic) NSString *inviteLinkDestinationURL;

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