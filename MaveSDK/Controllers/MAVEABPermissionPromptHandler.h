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

@interface MAVEABPermissionPromptHandler : NSObject<UIAlertViewDelegate>

@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePromptTemplate *prePromptTemplate;
@property (nonatomic, copy) void(^completionBlock)(NSDictionary *contacts);
@property (nonatomic, strong) id retainSelf;

- (void)promptForContactsWithCompletionBlock:(void(^)(NSDictionary *indexedContacts))completionBlock;
- (void)showPrePromptAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                   cancelButtonCopy:(NSString *)cancelButtonCopy
                   acceptbuttonCopy:(NSString *)acceptButtonCopy;

- (void)logContactsPromptRelatedEventWithRoute:(NSString *)route;

@end
