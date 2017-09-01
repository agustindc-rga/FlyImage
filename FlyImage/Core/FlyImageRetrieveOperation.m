//
//  FlyImageRetrieveOperation.m
//  FlyImage
//
//  Created by Ye Tong on 8/11/16.
//  Copyright © 2016 Ye Tong. All rights reserved.
//

#import "FlyImageRetrieveOperation.h"

@implementation FlyImageRetrieveOperation {
    RetrieveOperationBlock _retrieveBlock;
    UIImage* _retrievedImage;
}

- (instancetype)initWithRetrieveBlock:(RetrieveOperationBlock)block
{
    if (self = [self init]) {
        _retrieveBlock = [block copy];
    }
    return self;
}

- (void)main
{
    if (self.isCancelled) {
        return;
    }
    _retrievedImage = _retrieveBlock();
}

- (void)cancel
{
    if (self.isFinished) {
        return;
    }
    [super cancel];
    _retrievedImage = nil;
}

- (UIImage*)retrievedImage
{
    return _retrievedImage;
}

@end

@implementation FlyImageRetrieveResultOperation {
    FlyImageRetrieveOperation *_retrieveOperation;
    FlyImageCacheRetrieveBlock _completionBlock;
}

- (instancetype)initWithRetrieveOperation:(FlyImageRetrieveOperation*)operation
                               completion:(FlyImageCacheRetrieveBlock)completion
{
    if (self = [self init]) {
        _retrieveOperation = operation;
        _completionBlock = [completion copy];
        
        [self addDependency:operation];
    }
    return self;
}

- (void)main
{
    if (self.isCancelled) {
        return;
    }
    if (_retrieveOperation.isCancelled) {
        [self cancel];
        return;
    }
    
    UIImage *image = [_retrieveOperation retrievedImage];
    _completionBlock(_retrieveOperation.name, image);
}

- (void)cancel
{
    if (self.isFinished) {
        return;
    }
    [super cancel];
    
    _completionBlock(_retrieveOperation.name, nil);
}

@end
