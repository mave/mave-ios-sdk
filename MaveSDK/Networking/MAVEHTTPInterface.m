//
//  MAVEHTTPInterface.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/2/15.
//
//

#import "MAVEHTTPInterface.h"

@implementation MAVEHTTPInterface

- (instancetype)init {
    if (self = [super init]) {
        self.httpStack = [[MAVEHTTPStack alloc] init];
    }
    return self;
}

@end
