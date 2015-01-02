//
//  MAVEHTTPInterface.h
//  MaveSDK
//
//  A session-aware interface to http requests for our app, appends the device & user information
//  and authentication parameters that our API expects on every request.
//  Created by Danny Cosson on 1/2/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEHTTPStack.h"

@interface MAVEHTTPInterface : NSObject

@property (nonatomic, strong) MAVEHTTPStack *httpStack;

@end
