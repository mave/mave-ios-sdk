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

+ (void)promptForContactsWithCompletionBlock:(void(^)(NSDictionary *indexedContacts))completionBlock;

@end
