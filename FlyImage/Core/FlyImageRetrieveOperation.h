//
//  FlyImageRetrieveOperation.h
//  FlyImage
//
//  Created by Ye Tong on 8/11/16.
//  Copyright © 2016 Ye Tong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyImageCacheProtocol.h"

typedef UIImage* (^RetrieveOperationBlock)(void);

/**
 *  Internal class. In charge of retrieving a UIImage.
 */
@interface FlyImageRetrieveOperation : NSOperation

/**
 *  When the operation starts running, the block will be executed,
 *  and it should return an uncompressed UIImage.
 */
- (instancetype)initWithRetrieveBlock:(RetrieveOperationBlock)block;

/**
 *  The image retrieved by the operation, or `nil` if the operation is cancelled or never executes.
 */
- (UIImage*)retrievedImage;

@end

/**
 * Internal class. In charge of sending a UIImage retrieved from a previous operation.
 */
@interface FlyImageRetrieveResultOperation : NSOperation

/**
 *  Once the retrieve operation completes, the block will be executed,
 *  and it will receive the retrieved image or `nil` if the operation was cancelled.
 */
- (instancetype)initWithRetrieveOperation:(FlyImageRetrieveOperation*)operation
                               completion:(FlyImageCacheRetrieveBlock)completion;

@end
