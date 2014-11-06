//
//  GRKUserData.m
//  GrowthKit
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import "GRKUserData.h"

#define UserDataKeyUserID @"user_id"
#define UserDataKeyFirstName @"first_name"
#define UserDataKeyLastName @"last_name"
#define UserDataKeyEmail @"email"
#define UserDataKeyPhone @"phone"

@implementation GRKUserData

- (instancetype)initWithUserID:(NSString *)userID
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName
                         email:(NSString *)email
                         phone:(NSString *)phone {
    if (self = [self init]) {
        self.userID = userID;
        self.firstName = firstName;
        self.lastName = lastName;
        self.email = email;
        self.phone = phone;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    if (self.userID) [output setObject:self.userID forKey:UserDataKeyUserID];
    if (self.firstName) [output setObject:self.firstName forKey:UserDataKeyFirstName];
    if (self.lastName) [output setObject:self.lastName forKey:UserDataKeyLastName];
    if (self.email) [output setObject:self.email forKey:UserDataKeyEmail];
    if (self.phone) [output setObject:self.phone forKey:UserDataKeyPhone];
    return (NSDictionary *)output;
}

- (NSDictionary *)toDictionaryIDOnly {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    if (self.userID) [output setObject:self.userID forKey:UserDataKeyUserID];
    return (NSDictionary *)output;
}

@end
