//
//  MAVEConstants.m
//  MaveSDK
//
//  Created by dannycosson on 10/15/14.
//
//

#import "MAVEConstants.h"


#ifdef MAVE_USE_DEV_API
    NSString * const MAVEAPIBaseURL = @"http://devapi.mave.io/";
#else
    NSString * const MAVEAPIBaseURL = @"http://api.mave.io/";
#endif
NSString * const MAVEAPIVersion = @"v1.0";

#ifdef MAVE_USE_DEV_API
    NSString * const MAVEShortLinkBaseURL = @"http://dev.appjoin.us/";
#else
    NSString * const MAVEShortLinkBaseURL = @"http://dev.appjoin.us/";
#endif

// Debug log code
void MAVEExtendedLog(const char*prefix, const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    // Type to hold information about variable arguments.
    va_list ap;

    // Initialize a variable argument list.
    va_start (ap, format);

    // regular ns log only adds a newline to the end of the format if
    // one is not already there.
    // Here we are utilizing this feature
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }

    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];

    // End using variable argument list.
    va_end (ap);

    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "%s %s:%d: %s",
            prefix,
            [fileName UTF8String],
            lineNumber,
            [body UTF8String]);
}


NSString * const MAVE_HTTP_ERROR_DOMAIN = @"com.mave.http.error";
NSInteger const MAVEHTTPErrorRequestJSONCode = 1000;
NSInteger const MAVEHTTPErrorResponseIsNotJSONCode = 1010;
NSInteger const MAVEHTTPErrorResponseJSONCode = 1011;
NSInteger const MAVEHTTPErrorResponseNilCode = 1012;
NSInteger const MAVEHTTPErrorResponse400LevelCode = 400;
NSInteger const MAVEHTTPErrorResponse500LevelCode = 500;

NSString * const MAVE_VALIDATION_ERROR_DOMAIN = @"com.mave.validation.error";
NSInteger const MAVEValidationErrorApplicationIDNotSetCode = 100;
NSInteger const MAVEValidationErrorUserIdentifyNeverCalledCode = 110;
NSInteger const MAVEValidationErrorUserIDNotSetCode = 111;
NSInteger const MAVEValidationErrorUserNameNotSetCode = 112;
NSInteger const MAVEValidationErrorDismissalBlockNotSetCode = 120;

///
/// Application IDs to hard-code features for specific early beta partners
///
NSString *const MAVEPartnerApplicationIDSwig = @"549627813558889";
NSString *const MAVEPartnerApplicationIDSwigEleviter = @"571085046001449";
NSString *const MAVEInviteURLSwig = @"http://appjoin.us/MTYz";
            
///
/// Country Codes
///
NSString *const MAVECountryCodeUnitedStates = @"US";
NSString *const MAVECountryCodeRussia = @"RU";