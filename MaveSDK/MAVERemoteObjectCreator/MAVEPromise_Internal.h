//
//  MAVEPromise_Internal.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import "MAVEPromise.h"

#ifndef MaveSDK_MAVEPromise_Internal_h
#define MaveSDK_MAVEPromise_Internal_h

@interface MAVEPromise ()

@property (nonatomic, strong) NSValue *value;
@property (nonatomic) dispatch_semaphore_t gcd_semaphore;

@end


#endif
