//
//  MAVERemoteConfigurationClientEmail.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationClientEmail.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVETemplatingUtils.h"
#import "MaveSDK.h"
#import "MAVESharer.h"

NSString * const MAVERemoteConfigKeyClientEmailTemplate = @"template";
NSString * const MAVERemoteConfigKeyClientEmailTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyClientEmailSubject = @"subject_template";
NSString * const MAVERemoteConfigKeyClientEmailBody = @"body_template";

@implementation MAVERemoteConfigurationClientEmail

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyClientEmailTemplate];

        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyClientEmailTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *subject = [template objectForKey:MAVERemoteConfigKeyClientEmailSubject];
        if (![subject isEqual:[NSNull null]]) {
            self.subjectTemplate = subject;
        }
        NSString *body = [template objectForKey:MAVERemoteConfigKeyClientEmailBody];
        if (![body isEqual:[NSNull null]]) {
            self.bodyTemplate = body;
        }
        if (!self.subjectTemplate || !self.bodyTemplate) {
            return nil;
        }
    }
    return self;
}

- (NSString *)subject {
    // NB: don't append link to subject if none b/c subject doesn't need link,
    // but still render template with it in case anyone tries to use it
    // if we generate link, email should use an "e" to designate
    NSString *link = [MAVESharer shareLinkWithSubRouteLetter:@"e"];
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    return [MAVETemplatingUtils interpolateTemplateString:self.subjectTemplate withUser:user link:link];
}

- (NSString *)body {
    // if we generate link, email should use an "e" to designate
    NSString *link = [MAVESharer shareLinkWithSubRouteLetter:@"e"];
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    return [MAVETemplatingUtils interpolateTemplateString:self.bodyTemplate withUser:user link:link];
}

+ (NSDictionary *)defaultJSONData {
    NSString *subject = [NSString stringWithFormat:@"Join %@",
                         [MAVEClientPropertyUtils appName]];
    NSString *body = [NSString stringWithFormat:@"Hey, I've been using %@ and thought you might like it. Check it out:\n\n{{ link }}",
                      [MAVEClientPropertyUtils appName]];
    return  @{
        MAVERemoteConfigKeyClientEmailTemplate: @{
            MAVERemoteConfigKeyClientEmailTemplateID: @"0",
            MAVERemoteConfigKeyClientEmailSubject: subject,
            MAVERemoteConfigKeyClientEmailBody: body,
        }
    };
}

@end
