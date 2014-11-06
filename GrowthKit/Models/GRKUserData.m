//
//  GRKUserData.m
//  GrowthKit
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import "GRKUserData.h"

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

@end
