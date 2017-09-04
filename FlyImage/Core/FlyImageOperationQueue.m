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
    long _totalCount;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _retrievingQueue = [NSOperationQueue new];
        _retrievingQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        _retrievingQueue.maxConcurrentOperationCount = 6;
        _totalCount = 0;
    }
    return self;
}

- (NSOperation*)operationWithName:(NSString*)name
{
    NSParameterAssert(name != nil);
    
    for (NSOperation* operation in _retrievingQueue.operations) {
        if (!operation.cancelled && !operation.finished && [operation.name isEqualToString:name]) {
            return operation;
        }
    }
    return nil;
}

- (FlyImageRetrieveOperation*)retrieveOperationWithName:(NSString*)name
{
    id operation = [self operationWithName:name];
    return [operation isKindOfClass:[FlyImageRetrieveOperation class]] ? operation : nil;
}

- (FlyImageRetrieveResultOperation*)addCompletionForOperation:(FlyImageRetrieveOperation*)operation block:(FlyImageCacheRetrieveBlock)block
{
    FlyImageRetrieveResultOperation *resultOperation = [[FlyImageRetrieveResultOperation alloc] initWithRetrieveOperation:operation completion:block];
    
    _totalCount++;
    resultOperation.name = [NSString stringWithFormat:@"%@.%li", operation.name, _totalCount];
    return resultOperation;
}

- (int)countOperationsWithDependencies:(NSArray*)dependencies
{
    int dependencyCount = 0;
    for (NSOperation* op in _retrievingQueue.operations) {
        if (!op.cancelled && !op.finished && [op.dependencies isEqualToArray:dependencies]) {
            dependencyCount++;
        }
    }
    return dependencyCount;
}

#pragma mark -

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
    [_retrievingQueue addOperation:operation];
    
    FlyImageRetrieveResultOperation *resultOperation = [self addCompletionForOperation:operation block:completionBlock];
    [_retrievingQueue addOperation:resultOperation];
    
    return resultOperation;
}

- (FlyImageOperationIdentifier)updateOperationWithName:(NSString*)name
                                       completionBlock:(FlyImageCacheRetrieveBlock)completionBlock
{
    FlyImageRetrieveOperation* operation = [self retrieveOperationWithName:name];
    if (operation == nil) {
        return nil;
    }
    
    FlyImageRetrieveResultOperation *resultOperation = [self addCompletionForOperation:operation block:completionBlock];
    [_retrievingQueue addOperation:resultOperation];
    
    return resultOperation;
}

- (void)cancelAllOperations
{
    [_retrievingQueue cancelAllOperations];
}

- (void)cancelAllOperationsWithName:(NSString*)name
{
    if (name == nil) {
        return;
    }
    NSOperation* operation = [self operationWithName:name];
    [operation cancel];
}

- (void)cancelOperationForIdentifier:(FlyImageOperationIdentifier)identifier
{
    if (![identifier isKindOfClass:[FlyImageRetrieveResultOperation class]]) {
        return;
    }
    FlyImageRetrieveResultOperation *operation = identifier;
    
    if (![_retrievingQueue.operations containsObject:operation]) {
        return;
    }
    
    // count remaining operations with the same parent
    NSArray *dependencies = [operation dependencies];
    int dependencyCount = [self countOperationsWithDependencies:dependencies];

    // cancel the result operation
    [operation cancel];
    
    // cancel the parent operation if it only has one child (the operation being cancelled)
    if (dependencyCount < 2) {
        for (NSOperation *op in dependencies) {
            [op cancel];
        }
    }
}

@end
