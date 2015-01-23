//
//  MAVEABSyncManager.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEABSyncManager : NSObject

@property (nonatomic, strong) NSArray *personsArray;

- (instancetype)initWithAddressBookData:(NSArray *)personsArray;

@end
