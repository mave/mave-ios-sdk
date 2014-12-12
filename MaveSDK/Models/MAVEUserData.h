//
//  MAVEUserData.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import <Foundation/Foundation.h>


@interface MAVEUserData : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phone;

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

@end