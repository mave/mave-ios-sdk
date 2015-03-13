//
//  MAVEMerkleTreeUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/28/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEMerkleTreeUtils : NSObject

+ (NSData *)JSONSerialize:(id)object;
+ (NSData *)JSONSerialize:(id)object prettyPrinted:(BOOL)pretty;

@end
