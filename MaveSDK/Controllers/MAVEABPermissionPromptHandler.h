//
//  MAVEAddressBookPromptHandler.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAVEABPermissionPromptHandler : NSObject<UIAlertViewDelegate>

@property (nonatomic, copy) void(^completionBlock)(NSDictionary *contacts);
@property (nonatomic, strong) id retainSelf;
@property (nonatomic, copy) NSString *prePromptTemplateID;

- (void)promptForContactsWithCompletionBlock:(void(^)(NSDictionary *indexedContacts))completionBlock;
- (void)showPrePromptAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                   cancelButtonCopy:(NSString *)cancelButtonCopy
                   acceptbuttonCopy:(NSString *)acceptButtonCopy;

- (void)logContactsPromptRelatedEvent:(NSString *)eventRoute
                  prePromptTemplateID:(NSString *)templateID;

@end
