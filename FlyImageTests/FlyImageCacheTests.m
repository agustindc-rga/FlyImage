//
//  FlyImageCacheTests.m
//  Demo
//
//  Created by Norris Tong on 4/3/16.
//  Copyright © 2016 NorrisTong. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FlyImageCache.h"
#import "FlyImageDataFIleManager.h"

@interface FlyImageCacheTests : XCTestCase

@end

static FlyImageCache* _imageCache;
static CGFloat imageWidth = 1920.0;
static CGFloat imageHeight = 1200.0;
static FlyImageDataFileManager* _fileManager;
static int kMultipleTimes = 15;
static NSMutableArray* _addedImages;

@implementation FlyImageCacheTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _imageCache = [[FlyImageCache alloc] init];
    _fileManager = [_imageCache valueForKey:@"dataFileManager"];
    _addedImages = [[NSMutableArray alloc] init];
}

- (void)tearDown
{
    [self removeImages];
    
    _imageCache = nil;
    _fileManager = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)addImageFile:(NSString*)name
{
    // generate an image with special size
    CGRect rect = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData* imageData = UIImagePNGRepresentation(image);
    NSString* directoryPath = [_fileManager folderPath];
    NSString* imagePath = [directoryPath stringByAppendingPathComponent:name];
    [imageData writeToFile:imagePath atomically:YES];

    [_fileManager addExistFileName:name];
    [_addedImages addObject:imagePath];
}

- (void)removeImages
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (NSString* path in _addedImages) {
        [fileManager removeItemAtPath:path error:nil];
    }
    [_addedImages removeAllObjects];
}

- (void)drawALineInContext:(CGContextRef)context rect:(CGRect)rect
{
    UIGraphicsPushContext(context);

    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 10.0);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);

    UIGraphicsPopContext();
}

- (void)addToCacheWithFilename:(NSString*)filename
{
    XCTestExpectation* expectation = [self expectationWithDescription:@"addToCache"];
    
    [self addImageFile:filename];
    
    [_imageCache addImageWithKey:filename filename:filename completed:^(NSString* key, UIImage* image) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)test10AddImage
{
    XCTestExpectation* expectation = [self expectationWithDescription:@"test10AddImage"];

    NSString* filename = @"10";
    [self addImageFile:filename];

    [_imageCache addImageWithKey:filename
                        filename:filename
                       completed:^(NSString* key, UIImage* image) {
                           XCTAssert( image.size.width == imageWidth );
                           XCTAssert( image.size.height == imageHeight );
                           
                           [expectation fulfill];
                       }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError* error) { XCTAssert(YES, @"Pass"); }];
}

- (void)test11AddMultipleTimes
{
    XCTestExpectation* expectation = [self expectationWithDescription:@"test11AddMultipleTimes"];

    NSString* filename = @"11";
    [self addImageFile:filename];

    __block int sum = 0;
    for (int i = 0; i < kMultipleTimes; i++) {

        [_imageCache addImageWithKey:filename
                            filename:filename
                           completed:^(NSString* key, UIImage* image) {
                               XCTAssert( image.size.width == imageWidth );
                               XCTAssert( image.size.height == imageHeight );
                               
                               sum++;
                               if ( sum == kMultipleTimes ){
                                   [expectation fulfill];
                               }
                           }];
    }

    [self waitForExpectationsWithTimeout:30 handler:^(NSError* error) { XCTAssert(YES, @"Pass"); }];
}

- (void)test13AddMultipleKeys
{
    XCTestExpectation* expectation = [self expectationWithDescription:@"test13AddMultipleKeys"];

    __block int sum = 0;
    for (int i = 1; i <= kMultipleTimes; i++) {

        NSString* filename = [NSString stringWithFormat:@"%d", i];
        [self addImageFile:filename];

        [_imageCache addImageWithKey:filename
                            filename:filename
                           completed:^(NSString* key, UIImage* image) {
                               XCTAssert( image.size.width == imageWidth );
                               XCTAssert( image.size.height == imageHeight );
                               
                               sum++;
                               if ( sum == kMultipleTimes ){
                                   [expectation fulfill];
                               }
                           }];
    }

    [self waitForExpectationsWithTimeout:100 handler:^(NSError* error) { XCTAssert(YES, @"Pass"); }];
}

- (void)test30AsyncGetImage
{
    NSString* filename = @"10";
    [self addToCacheWithFilename:filename];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"test30AsyncGetImage"];

    [_imageCache asyncGetImageWithKey:filename
                            completed:^(NSString* key, UIImage* image) {
        XCTAssert( image.size.width == imageWidth );
        XCTAssert( image.size.height == imageHeight );
        
        [expectation fulfill];
                            }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError* error) { XCTAssert(YES, @"Pass"); }];
}

- (void)test30AsyncGetImageMultipleTimes
{
    NSString* filename = @"10";
    [self addToCacheWithFilename:filename];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"test30AsyncGetImageMultipleTimes"];

    __block int sum = 0;
    for (int i = 0; i < kMultipleTimes; i++) {
        [_imageCache asyncGetImageWithKey:filename
                                 drawSize:CGSizeMake(500, 800)
                          contentsGravity:kCAGravityResizeAspect
                             cornerRadius:0
                                completed:^(NSString* key, UIImage* image) {
                               XCTAssert( image.size.width == 500 );
                               XCTAssert( image.size.height == 800 );
                               
                               sum++;
                               if ( sum == kMultipleTimes ){
                                   [expectation fulfill];
                               }
                                }];
    }

    [self waitForExpectationsWithTimeout:30 handler:^(NSError* error) { XCTAssert(YES, @"Pass"); }];
}

- (void)test40AsyncGetImageMultipleTimesAndCancelAll
{
    NSString* filename = @"40";
    [self addToCacheWithFilename:filename];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"test40AsyncGetImageMultipleTimesAndCancelAll"];
    
    __block int loadedCount = 0;
    __block int canceledCount = 0;
    for (int i = 0; i < kMultipleTimes; i++) {
        [_imageCache asyncGetImageWithKey:filename
                                 drawSize:CGSizeMake(500, 800)
                          contentsGravity:kCAGravityResizeAspect
                             cornerRadius:0
                                completed:^(NSString* key, UIImage* image) {
                                    if (image) {
                                        loadedCount++;
                                    } else {
                                        canceledCount++;
                                    }
                                    
                                    if (loadedCount + canceledCount == kMultipleTimes) {
                                        [expectation fulfill];
                                    }
                                }];
        if (i == kMultipleTimes - 1) {
            [_imageCache cancelGetImageOperationsForKey:filename];
        }
    }
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError* error) {
        XCTAssertEqual(canceledCount, kMultipleTimes, @"Expected all active requests to be cancelled");
    }];
}

- (void)test41AsyncGetImageMultipleTimesAndCancelOne
{
    NSString* filename = @"41";
    [self addToCacheWithFilename:filename];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"test41AsyncGetImageMultipleTimesAndCancelOne"];
    
    __block int loadedCount = 0;
    __block int canceledCount = 0;
    for (int i = 0; i < kMultipleTimes; i++) {
        __block FlyImageOperationIdentifier fetchOperation =
        [_imageCache asyncGetImageWithKey:filename
                                 drawSize:CGSizeMake(500, 800)
                          contentsGravity:kCAGravityResizeAspect
                             cornerRadius:0
                                completed:^(NSString* key, UIImage* image) {
                                    if (image) {
                                        loadedCount++;
                                    } else {
                                        canceledCount++;
                                    }

                                    if (loadedCount + canceledCount == kMultipleTimes) {
                                        [expectation fulfill];
                                    }
                                }];
        if (i == kMultipleTimes/2) {
            [_imageCache cancelGetImageOperation:fetchOperation];
        }
    }
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError* error) {
        XCTAssertEqual(canceledCount, 1, @"Expected only one request to be cancelled");
    }];
}

- (void)test50RemoveImage
{
    NSString* imageKey = @"11";
    [self addToCacheWithFilename:imageKey];
    
    XCTAssert([_imageCache imageExistsWithKey:imageKey]);
    [_imageCache removeImageWithKey:imageKey];
    XCTAssert(![_imageCache imageExistsWithKey:imageKey]);
}

- (void)test60ImagePath
{
    NSString* filename = @"10";
    [self addToCacheWithFilename:filename];
    
    XCTAssert([_imageCache imagePathWithKey:@"10"] != nil);
    XCTAssert([_imageCache imagePathWithKey:@"11"] == nil);
}

- (void)test80ChangeImageKey
{
    NSString* filename = @"10";
    [self addToCacheWithFilename:filename];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"test80ChangeImageKey"];

    XCTAssert(![_imageCache imageExistsWithKey:@"newKey"]);
    [_imageCache changeImageKey:@"10" newKey:@"newKey"];
    XCTAssert(![_imageCache imageExistsWithKey:@"10"]);
    XCTAssert([_imageCache imageExistsWithKey:@"newKey"]);

    [_imageCache asyncGetImageWithKey:@"newKey" completed:^(NSString* key, UIImage* image) {
        XCTAssert( image.size.width == imageWidth );
        XCTAssert( image.size.height == imageHeight );
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError* error) { XCTAssert(YES, @"Pass"); }];
}

- (void)test90Purge
{
    NSString* filename = @"10";
    [self addToCacheWithFilename:filename];;
    
    XCTAssert([_imageCache imageExistsWithKey:@"10"]);
    [_imageCache purge];
    XCTAssert(![_imageCache imageExistsWithKey:@"10"]);
}

@end
