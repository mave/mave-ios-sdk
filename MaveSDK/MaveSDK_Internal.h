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
#import "MAVEPreFetchedHTTPRequest.h"

@interface MaveSDK (Internal)

@property (nonatomic, strong) MAVEPreFetchedHTTPRequest *preFetchedRemoteConfigurationRequest;

- (instancetype)initWithAppId:(NSString *)appId;

- (void)trackAppOpen;

// This function checks that required fields for the MaveSDK invite page to work
// correctly aren't nil. If it fails we return nil for the invite page view controller.
- (NSError *)validateSetup;
// Validate just the user info related required setup fields
- (NSError *)validateUserSetup;


@end