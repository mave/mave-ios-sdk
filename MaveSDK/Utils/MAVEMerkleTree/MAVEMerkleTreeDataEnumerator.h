//
//  MAVEMerkleTreeDataIterable.h
//  MaveSDK
//
//  This is an enumerator that gives a collection of data with which to build
//  a merkle tree, it's a collection of any type of object.
//  
//  Created by Danny Cosson on 1/26/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEMerkleTreeDataEnumerator : NSEnumerator

@property (nonatomic, strong) NSEnumerator *enumerator;
@property (nonatomic, strong) id _nextObject;

@property (nonatomic, copy) NSUInteger (^blockThatReturnsHashKey)(id object);
@property (nonatomic, copy) NSData *(^blockToSerializeDataBlock)(NSArray *array);

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator
           blockThatReturnsHashKey:(NSUInteger (^)(id object))block;

- (id)peekAtNextObject;

- (NSUInteger)keyForNextObject;

@end
