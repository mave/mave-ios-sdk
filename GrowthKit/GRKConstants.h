//
//  GRKConstants.h
//  GrowthKit
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

extern NSString * const GRK_ERROR_DOMAIN;

extern NSInteger const GRKHTTPErrorRequestJSONCode;
extern NSInteger const GRKHTTPErrorResponseIsNotJSONCode;
extern NSInteger const GRKHTTPErrorResponseJSONCode;
extern NSInteger const GRKHTTPErrorResponseNilCode;
extern NSInteger const GRKHTTPErrorResponse400LevelCode;
extern NSInteger const GRKHTTPErrorResponse500LevelCode;