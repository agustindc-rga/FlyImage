//
//  FlyImageRetrieveOperation.m
//  FlyImage
//
//  Created by Ye Tong on 8/11/16.
//  Copyright © 2016 Ye Tong. All rights reserved.
//

#import "FlyImageRetrieveOperation.h"

@interface FlyImageRetrieveObserver()

@property (nonatomic) NSString *name;
@property (nonatomic, copy) FlyImageCacheRetrieveBlock block;

@end

@implementation FlyImageRetrieveObserver
@end


@implementation FlyImageRetrieveOperation {
    NSMutableArray* _blocks;
    RetrieveOperationBlock _retrieveBlock;
}

- (instancetype)initWithRetrieveBlock:(RetrieveOperationBlock)block
{
    if (self = [self init]) {
        _retrieveBlock = block;
    }
    return self;
}

- (FlyImageRetrieveObserver*)addObserverUsingBlock:(FlyImageCacheRetrieveBlock)block
{
    if (_blocks == nil) {
        _blocks = [NSMutableArray new];
    }
    
    FlyImageRetrieveObserver *observer = [[FlyImageRetrieveObserver alloc] init];
    observer.name = self.name;
    observer.block = block;
    [_blocks addObject:observer];
    
    return observer;
}

- (void)cancelObserver:(FlyImageRetrieveObserver*)observer
{
    NSUInteger index = [_blocks indexOfObject:observer];
    if (index != NSNotFound) {
        FlyImageRetrieveObserver *observer = _blocks[index];
        [_blocks removeObjectAtIndex:index];
        
        observer.block(self.name, nil);
    }
}

- (BOOL)hasActiveObservers
{
    return [_blocks count] > 0;
}

- (void)executeWithImage:(UIImage*)image
{
    NSArray *blocks = [_blocks copy];
    [_blocks removeAllObjects];
    
    for (FlyImageRetrieveObserver *observer in blocks) {
        observer.block(self.name, image);
    }
}

- (void)main
{
    if (self.isCancelled) {
        return;
    }

    UIImage* image = _retrieveBlock();
    [self executeWithImage:image];
}

- (void)cancel
{
    if (self.isFinished)
        return;
    [super cancel];

    [self executeWithImage:nil];
}

@end
