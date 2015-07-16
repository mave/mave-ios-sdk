//
//  MAVEConstants.h
//  MaveSDK
//
//  Created by dannycosson on 10/15/14.
//
//

#import <Foundation/Foundation.h>

// Macro for logging. Debug logging should only show up with a special MAVE_DEBUG_LOG
#if defined(DEBUG)

  #if defined(MAVE_DEBUG_LOG)
    #define MAVEDebugLog(args...) MAVEExtendedLog("MAVE [DEBUG]", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
  #else
    #define MAVEDebugLog(args...) MAVENoopLog(args)
  #endif

  #define MAVEInfoLog(args...) MAVEExtendedLog("MAVE [INFO]", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
  #define MAVEErrorLog(args...) MAVEExtendedLog("MAVE [ERROR]", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);

#else
  #define MAVEDebugLog(args...) MAVENoopLog(args);
  #define MAVEInfoLog(args...) MAVENoopLog(args);
  #define MAVEErrorLog(args...) MAVENoopLog(args);
#endif

// Custom log & reporting functions
void MAVEExtendedLog(const char*prefix, const char *file, int lineNumber, const char *functionName, NSString *format, ...);
void MAVENoopLog(NSString *format, ...);

extern NSString * const MAVESDKVersion;
extern NSString * const MAVEAPIBaseURL;
extern NSString * const MAVEAPIVersion;
extern NSString * const MAVEShortLinkBaseURL;


// App-device-id storage user defaults (should never get cleared,
// want this to be as permanent as possible as an id for the device)
extern NSString * const MAVEUserDefaultsKeyAppDeviceID;

// Key where we cache the user data set by the application
extern NSString *const MAVEUserDefaultsKeyUserData;
extern NSString *const MAVEUserDefaultsKeyLinkDetails;

// Server response cache user defaults
extern NSString * const MAVEUserDefaultsKeyRemoteConfiguration;
extern NSString * const MAVEUserDefaultsKeyShareToken;

// Cocoapods resource bundle name
extern NSString * const MAVEResourceBundleName;

// Custom HTTP Errors
extern NSString * const MAVE_HTTP_ERROR_DOMAIN;
extern NSInteger const MAVEHTTPErrorRequestJSONCode;
extern NSInteger const MAVEHTTPErrorResponseIsNotJSONCode;
extern NSInteger const MAVEHTTPErrorResponseJSONCode;
extern NSInteger const MAVEHTTPErrorResponseNilCode;
extern NSInteger const MAVEHTTPErrorResponse400LevelCode;
extern NSInteger const MAVEHTTPErrorResponse500LevelCode;

// Custom validation errors
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
extern NSString *const MAVECountryCodeCanada;
extern NSString *const MAVECountryCodeRussia;
