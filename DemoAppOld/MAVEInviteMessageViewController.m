//
//  MAVEInviteMessageViewController.m
//  MaveDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//


#import "AFNetworking.h"
#import "Mave.h"
#import <UIKit/UIKit.h>
#import "MAVEInviteMessageViewController.h"
#import "MAVEInviteMessageView.h"

@implementation MAVEInviteMessageViewController

- (MAVEInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame delegate:(MAVEInvitePageViewController *)delegate selectedPhones:(NSMutableSet *)selectedPhones {
    self = [self init];
    self.delegate = delegate;
    self.selectedPhones = selectedPhones;
    self.view = [[MAVEInviteMessageView alloc] initCustomWithFrame:frame];
    self.messageTextField = self.view.textField;
    [self.view.sendButton addTarget:self action:@selector(sendInvites:) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)sendInvites:(id)sender {
    NSString *appToken = @"e2788bf35c8d1fea98b1bd0d25ec11ec";
    
    // NSLog(@"Would send '%@' to: %@", self.messageTextField.text, _selectedPhones);
    NSString *baseURL = @"http://devaccounts.growthkit.io/v1.0";
    NSString *urlString = [baseURL stringByAppendingString:@"/invites"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSArray *phonesToInvite = [self.selectedPhones allObjects];
    
    NSDictionary *params = @{
        @"app_token": appToken,
        @"recipients": phonesToInvite,
        @"sms_copy": self.messageTextField.text,
    };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Oh no error serializing dict to json!");
    }
    NSLog(@"Logged dict to json: %@", params);
    [request  setHTTPBody:jsonData];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
    }];
    [operation start];
}

@end
