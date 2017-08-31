//
//  FlyImageRetrieveOperation.h
//  FlyImage
//
//  Created by Ye Tong on 8/11/16.
//  Copyright © 2016 Ye Tong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyImageCacheProtocol.h"

/**
 * Internal class.
 */
@interface FlyImageRetrieveObserver : NSObject

@property (nonatomic, readonly) NSString *name;

@end


typedef UIImage* (^RetrieveOperationBlock)(void);

/**
 *  Internal class. In charge of retrieving and sending UIImage.
 */
@interface FlyImageRetrieveOperation : NSOperation

/**
 *  When the operation starts running, the block will be executed,
 *  and it should return an uncompressed UIImage.
 */
- (instancetype)initWithRetrieveBlock:(RetrieveOperationBlock)block;

/**
 *  Add an observer that will call the given block when the operation completes
 *  or is cancelled. The newly created observer is returned to the caller to
 *  allow cancelling the observation.
 *
 *  @param block
 */
- (FlyImageRetrieveObserver*)addObserverUsingBlock:(FlyImageCacheRetrieveBlock)block;

/**
 *  The given observer will no longer be notified when the operation completes. The
 *  block associated with the observer will be called as if the operation was cancelled.
 *
 *  @param observer
 */
- (void)cancelObserver:(FlyImageRetrieveObserver*)observer;

/**
 *  Returns YES if there are any observers that will be notified when the operation completes.
 */
- (BOOL)hasActiveObservers;

/**
 *  Callback with result image, which can be nil.
 */
- (void)executeWithImage:(UIImage*)image;

@end
