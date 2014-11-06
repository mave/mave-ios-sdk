//
//  GRKConstants.m
//  GrowthKit
//
//  Created by dannycosson on 10/15/14.
//
//

#import "GRKConstants.h"


#ifdef USE_DEV_API
    NSString * const GRKAPIBaseURL = @"http://devapi.mave.io/";
#else
    NSString * const GRKAPIBaseURL = @"http://api.mave.io/";
#endif
NSString * const GRKAPIVersion = @"v1.0";

NSString * const GRK_HTTP_ERROR_DOMAIN = @"com.growthkit.http.error";
NSInteger const GRKHTTPErrorRequestJSONCode = 1000;
NSInteger const GRKHTTPErrorResponseIsNotJSONCode = 1010;
NSInteger const GRKHTTPErrorResponseJSONCode = 1011;
NSInteger const GRKHTTPErrorResponseNilCode = 1012;
NSInteger const GRKHTTPErrorResponse400LevelCode = 400;
NSInteger const GRKHTTPErrorResponse500LevelCode = 500;


NSString * const GRK_VALIDATION_ERROR_DOMAIN = @"com.growthkit.validation.error";
NSInteger const GRKValidationErrorApplicationIDNotSetCode = 100;
NSInteger const GRKValidationErrorUserIDNotSetCode = 101;
NSInteger const GRKValidationErrorUserNameNotSetCode = 102;