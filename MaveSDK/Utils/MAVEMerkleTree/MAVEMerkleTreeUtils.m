//
//  MAVEMerkleTreeUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/28/15.
//
//

#import "MAVEMerkleTreeUtils.h"

@implementation MAVEMerkleTreeUtils

+ (NSData *)JSONSerialize:(id)object {
    NSError *err;
    NSData *output = [NSJSONSerialization dataWithJSONObject:object options:0 error:&err];
    if (err) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree - error %@ serializing object: %@",
              err, object);
#endif
        return nil;
    }
    return output;
}

@end
