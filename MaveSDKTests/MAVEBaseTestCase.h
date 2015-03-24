//
//  MAVETestBase.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/23/15.
//
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface MAVEBaseTestCase : XCTestCase

- (void)resetTestState;

@end