//
//  FlyImageOperationQueue.h
//  FlyImage
//
//  Created by Agustin De Cabrera on 8/24/17.
//  Copyright © 2017 Augmn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyImageCacheProtocol.h"
#import "FlyImageRetrieveOperation.h"

/**
 */
@interface FlyImageOperationQueue : NSObject

// Get

- (FlyImageRetrieveOperation*)operationWithName:(NSString*)name;

// Add

- (FlyImageOperationIdentifier)addOperationWithName:(NSString*)name
                                      retrieveBlock:(RetrieveOperationBlock)block
                                    completionBlock:(FlyImageCacheRetrieveBlock)completion;

// Cancel

- (void)cancelAllOperations;

- (void)cancelOperationWithName:(NSString*)name;

- (void)cancelOperationForIdentifier:(FlyImageOperationIdentifier)identifier;

@end
