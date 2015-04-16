//
//  MAVEAddressBookPromptHandler.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAVERemoteConfiguration.h"

typedef void (^MAVEABDataBlock)(NSArray *contacts);

@interface MAVEABPermissionPromptHandler : NSObject<UIAlertViewDelegate>

@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePrompt *prePromptTemplate;
@property (nonatomic, copy) void(^completionBlock)(NSArray *contacts);
@property (nonatomic, strong) id retainSelf;
@property (nonatomic) BOOL beganFlowAsStatusUnprompted;

// This is the entry point for this class, use this method to prompt for contacts
// after initializing the object with alloc initCustom
// It will retain itself until user completes prompts so no need to do anything
// with the return value here
+ (instancetype)promptForContactsWithCompletionBlock:(MAVEABDataBlock)completionBlock;

// Loads the address book and returns the results immediately (formatted as an array
// of MAVEABPerson objects, if permission is already granted.
// If permission is not yet prompted or already denied, just return nil.
// Run in a background process since it makes an async method synchronous.
// Meant for when we want to do something with the address book if we already have it,
// at a point where it wouldn't make sense to prompt the user.
+ (NSArray *)loadAddressBookSynchronouslyIfPermissionGranted;
// Underlying method, loads address book synchronously without checking if permission
// granted, so will prompt user for permission if unprompted
+ (NSArray *)loadAddressBookSynchronously;

- (instancetype)initCustom;

// Underlying methods for different scenarios
// Shows pre-prompt
- (void)showPrePromptAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                   cancelButtonCopy:(NSString *)cancelButtonCopy
                   acceptbuttonCopy:(NSString *)acceptButtonCopy;

// Loads the address book and calls the completion block with results
// If permission has not yet been asked for it will prompt user when called
- (void)loadAddressBookAndComplete;

- (void)completeAfterPermissionGranted:(NSArray *)MAVEABPersonsArray;
- (void)completeAfterPermissionDenied;

- (void)logContactsPromptRelatedEventWithRoute:(NSString *)route;

@end
