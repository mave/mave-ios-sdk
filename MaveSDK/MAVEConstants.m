//
//  MAVEConstants.m
//  MaveSDK
//
//  Created by dannycosson on 10/15/14.
//
//

#import "MAVEConstants.h"


#ifdef USE_DEV_API
    NSString * const MAVEAPIBaseURL = @"http://devapi.mave.io/";
#else
    NSString * const MAVEAPIBaseURL = @"http://api.mave.io/";
#endif
NSString * const MAVEAPIVersion = @"v1.0";

NSString * const MAVE_HTTP_ERROR_DOMAIN = @"com.growthkit.http.error";
NSInteger const MAVEHTTPErrorRequestJSONCode = 1000;
NSInteger const MAVEHTTPErrorResponseIsNotJSONCode = 1010;
NSInteger const MAVEHTTPErrorResponseJSONCode = 1011;
NSInteger const MAVEHTTPErrorResponseNilCode = 1012;
NSInteger const MAVEHTTPErrorResponse400LevelCode = 400;
NSInteger const MAVEHTTPErrorResponse500LevelCode = 500;


NSString * const MAVE_VALIDATION_ERROR_DOMAIN = @"com.growthkit.validation.error";
NSInteger const MAVEValidationErrorApplicationIDNotSetCode = 100;
NSInteger const MAVEValidationErrorUserIDNotSetCode = 101;
NSInteger const MAVEValidationErrorUserNameNotSetCode = 102;