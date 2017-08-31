//
//  FlyImageOperationQueue.m
//  FlyImage
//
//  Created by Agustin De Cabrera on 8/24/17.
//  Copyright © 2017 Augmn. All rights reserved.
//

#import "FlyImageOperationQueue.h"
#import "FlyImageRetrieveOperation.h"

#import "FlyImageCache.h"

@implementation FlyImageOperationQueue {
    NSOperationQueue* _retrievingQueue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _retrievingQueue = [NSOperationQueue new];
        _retrievingQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        _retrievingQueue.maxConcurrentOperationCount = 6;
    }
    return self;
}

- (FlyImageRetrieveOperation*)operationWithName:(NSString*)name
{
    NSParameterAssert(name != nil);
    
    for (FlyImageRetrieveOperation* operation in _retrievingQueue.operations) {
        if (!operation.cancelled && !operation.finished && [operation.name isEqualToString:name]) {
            return operation;
        }
    }
    return nil;
}

- (void)addOperation:(FlyImageRetrieveOperation*)operation
{
    [_retrievingQueue addOperation:operation];
}

- (FlyImageOperationIdentifier)addOperationWithName:(NSString*)name
                                      retrieveBlock:(RetrieveOperationBlock)retrieveBlock
                                    completionBlock:(FlyImageCacheRetrieveBlock)completionBlock;
{
    FlyImageRetrieveOperation* operation = [[FlyImageRetrieveOperation alloc] initWithRetrieveBlock:retrieveBlock];
    operation.name = name;
    
    FlyImageRetrieveObserver *observer = [operation addObserverUsingBlock:completionBlock];
    [_retrievingQueue addOperation:operation];
    
    return observer;
}

- (void)cancelAllOperations
{
    [_retrievingQueue cancelAllOperations];
}

- (void)cancelOperationWithName:(NSString*)name
{
    if (name == nil) {
        return;
    }
    FlyImageRetrieveOperation* operation = [self operationWithName:name];
    
    [operation cancel];
}

- (void)cancelOperationForIdentifier:(FlyImageOperationIdentifier)identifier
{
    if (![identifier isKindOfClass:[FlyImageRetrieveObserver class]]) {
        return;
    }
    FlyImageRetrieveObserver *observer = identifier;
    if (observer.name == nil) {
        return;
    }
    
    FlyImageRetrieveOperation *operation = [self operationWithName:observer.name];
    [operation cancelObserver:observer];
    
    if (![operation hasActiveObservers]) {
        [operation cancel];
    }
}

@end
