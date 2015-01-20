//
//  MAVEUserData.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import "MAVEUserData.h"
#import "MaveSDK.h"
#import "MAVENameParsingUtils.h"
#import "MAVEClientPropertyUtils.h"

#define MAVEUserDataKeyFirstName @"first_name"
#define MAVEUserDataKeyLastName @"last_name"
#define MAVEUserDataKeyEmail @"email"
#define MAVEUserDataKeyPhone @"phone"

@implementation MAVEUserData

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

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [self init]) {
        self.userID = [dict objectForKey:MAVEUserDataKeyUserID];
        self.firstName = [dict objectForKey:MAVEUserDataKeyFirstName];
        self.lastName = [dict objectForKey:MAVEUserDataKeyLastName];
        self.email = [dict objectForKey:MAVEUserDataKeyEmail];
        self.phone = [dict objectForKey:MAVEUserDataKeyPhone];
    }
    return self;
}

- (instancetype)initAutomaticallyFromDeviceName {
    if (self = [self init]) {
        self.userID = [MaveSDK sharedInstance].appDeviceID;
        self.firstName = [MAVEClientPropertyUtils deviceUsersFirstName];
        self.lastName = [MAVEClientPropertyUtils deviceUsersLastName];
        self.isSetAutomaticallyFromDevice = YES;
    }
    return self;
}

- (BOOL)isUserInfoOkToSendServerSideSMS {
    // it's ok to send if they have a user id and first name
    return ([self.userID length] > 0
            && [self.firstName length] > 0);
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    if (self.userID) [output setObject:self.userID forKey:MAVEUserDataKeyUserID];
    if (self.firstName) [output setObject:self.firstName forKey:MAVEUserDataKeyFirstName];
    if (self.lastName) [output setObject:self.lastName forKey:MAVEUserDataKeyLastName];
    if (self.email) [output setObject:self.email forKey:MAVEUserDataKeyEmail];
    if (self.phone) [output setObject:self.phone forKey:MAVEUserDataKeyPhone];
    return (NSDictionary *)output;
}

- (NSDictionary *)toDictionaryIDOnly {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    if (self.userID) [output setObject:self.userID forKey:MAVEUserDataKeyUserID];
    return (NSDictionary *)output;
}

- (NSString *)fullName {
    NSString *output = self.firstName;
    if (self.lastName) {
        output = [NSString stringWithFormat:@"%@ %@", output, self.lastName];
    }
    return output;
}

@end
