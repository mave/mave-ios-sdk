//
//  GrowthKit_Internal.h
//  GrowthKit
//
//  Created by Danny Cosson on 11/6/14.
//
//

#ifndef GrowthKit_GrowthKit_Internal_h
#define GrowthKit_GrowthKit_Internal_h

#endif

#import "GrowthKit.h"

@interface GrowthKit (Internal)

- (void)trackAppOpen;

// This function checks that required fields for the GrowthKit invite page to work
// correctly aren't nil. If it fails we return nil for the invite page view controller.
- (NSError *)validateSetup;


@end