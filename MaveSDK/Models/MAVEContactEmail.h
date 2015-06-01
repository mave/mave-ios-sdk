//
//  MAVEContactEmail.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import "MAVEContactIdentifierBase.h"

@interface MAVEContactEmail : MAVEContactIdentifierBase

- (NSString *)domain;
- (BOOL)isGmail;

@end
