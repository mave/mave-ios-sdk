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

NSString * const MAVEUserDataKeyUserID = @"user_id";
NSString * const MAVEUserDataKeyFirstName = @"first_name";
NSString * const MAVEUserDataKeyLastName = @"last_name";
NSString * const MAVEUserDataKeyEmail = @"email";
NSString * const MAVEUserDataKeyPhone = @"phone";
NSString * const MAVEUserDataKeyPicture = @"picture";
NSString * const MAVEUserDataKeyPromoCode = @"promo_code";

@implementation MAVEUserData

- (instancetype)initBase {
    if (self = [super init]) {
        self.isSetAutomaticallyFromDevice = NO;
        self.wrapInviteLink = YES;
    }
    return self;
}

- (instancetype)initWithUserID:(NSString *)userID
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName {
    return [self initWithUserID:userID
                      firstName:firstName
                       lastName:lastName
                          email:nil
                          phone:nil];
}

- (instancetype)initWithUserID:(NSString *)userID
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName
                         email:(NSString *)email
                         phone:(NSString *)phone {
    if (self = [self initBase]) {
        self.userID = userID;
        self.firstName = firstName;
        self.lastName = lastName;
        self.email = email;
        self.phone = phone;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [self initBase]) {
        self.userID = [dict objectForKey:MAVEUserDataKeyUserID];
        self.firstName = [dict objectForKey:MAVEUserDataKeyFirstName];
        self.lastName = [dict objectForKey:MAVEUserDataKeyLastName];
        self.email = [dict objectForKey:MAVEUserDataKeyEmail];
        self.phone = [dict objectForKey:MAVEUserDataKeyPhone];
        self.promoCode = [dict objectForKey:MAVEUserDataKeyPromoCode];
        NSString *pictureURLStr = [dict objectForKey:MAVEUserDataKeyPicture];
        if (pictureURLStr && [pictureURLStr isKindOfClass:[NSString class]]) {
            self.picture = [NSURL URLWithString:pictureURLStr];
        }
    }
    return self;
}

- (instancetype)initAutomaticallyFromDeviceName {
    if (self = [self initBase]) {
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
    if (self.userID) [output setValue:self.userID forKey:MAVEUserDataKeyUserID];
    if (self.firstName) [output setValue:self.firstName forKey:MAVEUserDataKeyFirstName];
    if (self.lastName) [output setValue:self.lastName forKey:MAVEUserDataKeyLastName];
    if (self.email) [output setValue:self.email forKey:MAVEUserDataKeyEmail];
    if (self.phone) [output setValue:self.phone forKey:MAVEUserDataKeyPhone];
    if (self.picture) [output setValue:[self.picture absoluteString] forKey:MAVEUserDataKeyPicture];
    if (self.promoCode) [output setValue:self.promoCode forKey:MAVEUserDataKeyPromoCode];
    return (NSDictionary *)output;
}

- (NSDictionary *)toDictionaryIDOnly {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    if (self.userID) [output setObject:self.userID forKey:MAVEUserDataKeyUserID];
    return (NSDictionary *)output;
}

- (NSDictionary *)serializeLinkDetails {
    id linkDestination = self.inviteLinkDestinationURL ? self.inviteLinkDestinationURL : [NSNull null];
    id customData = self.customData ? self.customData : @{};
    return @{@"link_destination": linkDestination, @"wrap_invite_link": @(self.wrapInviteLink), @"custom_data": customData};
}

- (NSString *)fullName {
    NSString *output = self.firstName;
    if (self.lastName) {
        output = [NSString stringWithFormat:@"%@ %@", output, self.lastName];
    }
    return output;
}

@end
