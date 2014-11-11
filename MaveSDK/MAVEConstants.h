//
//  MAVEConstants.h
//  MaveSDK
//
//  Created by dannycosson on 10/15/14.
//
//

#import <Foundation/Foundation.h>

// Macro for debug logging
#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

extern NSString * const MAVEAPIBaseURL;
extern NSString * const MAVEAPIVersion;

extern NSString * const MAVE_HTTP_ERROR_DOMAIN;

extern NSInteger const MAVEHTTPErrorRequestJSONCode;
extern NSInteger const MAVEHTTPErrorResponseIsNotJSONCode;
extern NSInteger const MAVEHTTPErrorResponseJSONCode;
extern NSInteger const MAVEHTTPErrorResponseNilCode;
extern NSInteger const MAVEHTTPErrorResponse400LevelCode;
extern NSInteger const MAVEHTTPErrorResponse500LevelCode;

extern NSString * const MAVE_VALIDATION_ERROR_DOMAIN;
extern NSInteger const MAVEValidationErrorApplicationIDNotSetCode;
extern NSInteger const MAVEValidationErrorUserIDNotSetCode;
extern NSInteger const MAVEValidationErrorUserNameNotSetCode;
extern NSInteger const MAVEValidationErrorDismissalBlockNotSetCode;