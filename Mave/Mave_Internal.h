//
//  Mave_Internal.h
//  Mave
//
//  Created by Danny Cosson on 11/6/14.
//
//

#ifndef Mave_Mave_Internal_h
#define Mave_Mave_Internal_h

#endif

#import "Mave.h"

@interface Mave (Internal)

- (void)trackAppOpen;

// This function checks that required fields for the Mave invite page to work
// correctly aren't nil. If it fails we return nil for the invite page view controller.
- (NSError *)validateSetup;


@end