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
    return [self JSONSerialize:object prettyPrinted:NO];
}

+ (NSData *)JSONSerialize:(id)object prettyPrinted:(BOOL)pretty {
    NSJSONWritingOptions opts = 0;
    if (pretty) {
        opts = NSJSONWritingPrettyPrinted;
    }
    NSError *err;
    NSData *output = [NSJSONSerialization dataWithJSONObject:object options:opts error:&err];
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
