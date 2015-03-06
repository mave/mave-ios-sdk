//
//  MAVESharer.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/6/15.
//
//

#import "MAVESharer.h"
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVERemoteConfiguration.h"
#import "MaveShareToken.h"
#import "MAVEClientPropertyUtils.h"

@implementation MAVESharer

- (instancetype)initAndRetainSelf {
    if (self = [super init]) {
        self.retainedSelf = self;
    }
    return self;
}

- (void)releaseSelf {
    self.retainedSelf = nil;
}

#pragma mark - Helpers for building share content
- (MAVERemoteConfiguration *)remoteConfiguration {
    return [MaveSDK sharedInstance].remoteConfiguration;
}

- (NSString *)shareToken {
    MAVEShareToken *tokenObject = [[MaveSDK sharedInstance].shareTokenBuilder createObjectSynchronousWithTimeout:0];
    return tokenObject.shareToken;
}

- (NSString *)shareCopyFromCopy:(NSString *)shareCopy
      andLinkWithSubRouteLetter:(NSString *)letter {
    NSString* link = [self shareLinkWithSubRouteLetter:letter];
    NSString *outputText = shareCopy;
    if ([outputText length] == 0) {
        outputText = link;
    } else {
        // if string doesn't end in a whitespace char, append a regular space
        NSString *lastLetter = [outputText substringFromIndex:([outputText length] - 1)];
        if (![@[@" ", @"\n"] containsObject:lastLetter]) {
            outputText = [outputText stringByAppendingString:@" "];
        }
        outputText = [outputText stringByAppendingString:link];
    }
    return outputText;
}

- (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute {
    NSString *shareToken = [self shareToken];
    NSString *output;// = MAVEShortLinkBaseURL;

    if ([shareToken length] > 0) {
        NSString *shareToken = [self shareToken];
        output = [NSString stringWithFormat:@"%@%@/%@",
                  MAVEShortLinkBaseURL, subRoute, shareToken];
    } else {
        NSString * base64AppID = [MAVEClientPropertyUtils urlSafeBase64ApplicationID];
        output = [NSString stringWithFormat:@"%@o/%@/%@",
                  MAVEShortLinkBaseURL, subRoute, base64AppID];
    }
    return output;
}

- (void)resetShareToken {
    MAVEDebugLog(@"Resetting share token after share, was: %@", [self shareToken]);
    [MAVEShareToken clearUserDefaults];
    [MaveSDK sharedInstance].shareTokenBuilder = [MAVEShareToken remoteBuilder];
}

@end
