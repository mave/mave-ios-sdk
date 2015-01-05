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

typedef void (^MAVEABDataBlock)(NSDictionary *indexedContacts);

@interface MAVEABPermissionPromptHandler : NSObject<UIAlertViewDelegate>

@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePromptTemplate *prePromptTemplate;
@property (nonatomic, copy) void(^completionBlock)(NSDictionary *contacts);
@property (nonatomic, strong) id retainSelf;

// This is the entry point for this class, use this method to prompt for contacts
// after initializign the object with alloc init.
- (void)promptForContactsWithCompletionBlock:(MAVEABDataBlock)completionBlock;

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
