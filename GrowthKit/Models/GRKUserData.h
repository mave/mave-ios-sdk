//
//  GRKUserData.h
//  GrowthKit
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import <Foundation/Foundation.h>

@interface GRKUserData : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;

- (instancetype)initWithUserID:(NSString *)userID
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName
                         email:(NSString *)email
                         phone:(NSString *)phone;

// Convert to a dictionary, e.g. to be serialized as JSON for an API request
- (NSDictionary *)toDictionary;
// Serializes only the userID field to a dictionary
- (NSDictionary *)toDictionaryIDOnly;

@end
