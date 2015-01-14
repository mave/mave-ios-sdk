//
//  MaveSDK_Internal.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/6/14.
//
//

#ifndef MaveSDK_MaveSDK_Internal_h
#define MaveSDK_MaveSDK_Internal_h

#endif

#import "MaveSDK.h"

@interface MaveSDK (Internal)

- (instancetype)initWithAppId:(NSString *)appId;

- (void)trackAppOpen;

// This function checks that required fields for the MaveSDK invite page to work
// correctly have been initialized. It logs any errors with a big "ERROR"

// Temporary, wrappers to access default sms text and invite explanation copy
- (NSString *)defaultSMSMessageText;
- (NSString *)inviteExplanationCopy;


@end