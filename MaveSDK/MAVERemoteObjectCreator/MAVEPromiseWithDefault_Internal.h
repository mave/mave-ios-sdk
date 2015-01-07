//
//  MAVEPromiseWithDefault_Internal.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#ifndef MaveSDK_MAVEPromiseWithDefault_Internal_h
#define MaveSDK_MAVEPromiseWithDefault_Internal_h

@interface MAVEPromiseWithDefault ()

// Semaphore for blocking on return values
@property (atomic) dispatch_semaphore_t gcd_semaphore;

@end

#endif
