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
#define DebugLog(args...) MAVEExtendedLog("MAVE LOG", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define ErrorLog(args...) MAVEExtendedLog("MAVE ERROR!", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define DebugLog(s, ... )
#define ErrorLog(args...)
#endif

// Custom log & reporting functions
void MAVEExtendedLog(const char*prefix, const char *file, int lineNumber, const char *functionName, NSString *format, ...);

extern NSString * const MAVEAPIBaseURL;
extern NSString * const MAVEAPIVersion;
extern NSString * const MAVEShortLinkBaseURL;

extern NSString * const MAVE_HTTP_ERROR_DOMAIN;

extern NSInteger const MAVEHTTPErrorRequestJSONCode;
extern NSInteger const MAVEHTTPErrorResponseIsNotJSONCode;
extern NSInteger const MAVEHTTPErrorResponseJSONCode;
extern NSInteger const MAVEHTTPErrorResponseNilCode;
extern NSInteger const MAVEHTTPErrorResponse400LevelCode;
extern NSInteger const MAVEHTTPErrorResponse500LevelCode;

extern NSString * const MAVE_VALIDATION_ERROR_DOMAIN;
extern NSInteger const MAVEValidationErrorApplicationIDNotSetCode;
extern NSInteger const MAVEValidationErrorUserIdentifyNeverCalledCode;
extern NSInteger const MAVEValidationErrorUserIDNotSetCode;
extern NSInteger const MAVEValidationErrorUserNameNotSetCode;
extern NSInteger const MAVEValidationErrorDismissalBlockNotSetCode;

///
/// Application IDs to hard-code features for specific early beta partners
///
extern NSString * const MAVEPartnerApplicationIDSwig;
extern NSString * const MAVEPartnerApplicationIDSwigEleviter;
extern NSString * const MAVEInviteURLSwig;

///
/// Country Codes
///
extern NSString *const MAVECountryCodeUnitedStates;
extern NSString *const MAVECountryCodeRussia;