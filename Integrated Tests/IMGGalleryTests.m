//
//  IMGGalleryTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-19.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGIntegratedTestCase.h"

@interface IMGGalleryTests : IMGIntegratedTestCase

@end

@implementation IMGGalleryTests


- (void)testGalleryHot{
    
    __block BOOL isSuccess;
    __block NSMutableOrderedSet * j = [NSMutableOrderedSet new];
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    
    [IMGGalleryRequest hotGalleryPage:1 success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [IMGGalleryRequest hotGalleryPage:2 success:^(NSArray * images) {
            
            [j addObjectsFromArray:images];
            
            if(j.count == images.count)
                failBlock(nil);
            else
                isSuccess = YES;
            
        } failure:failBlock];
    });
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryTop{
    
    __block BOOL isSuccess;
    __block NSMutableOrderedSet * j = [NSMutableOrderedSet new];
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    
    [IMGGalleryRequest topGalleryPage:1 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [IMGGalleryRequest topGalleryPage:2 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
            
            [j addObjectsFromArray:images];
            
            if(j.count == images.count)
                failBlock(nil);
            else
                isSuccess = YES;
            
        } failure:failBlock];
    });
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryUser{
    
    __block BOOL isSuccess;
    __block NSMutableOrderedSet * j = [NSMutableOrderedSet new];
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    [IMGGalleryRequest userGalleryPage:1 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [IMGGalleryRequest userGalleryPage:2 withViralSort:YES showViral:YES success:^(NSArray * images) {
            
            [j addObjectsFromArray:images];
            
            if(j.count == images.count)
                failBlock(nil);
            else
                isSuccess = YES;
            
        } failure:failBlock];
    });
    
    expect(isSuccess).will.beTruthy();
}

-(void)testImageNotFound{
    
    __block BOOL isSuccess = NO;
    
    //should fail request with not found
    
    [IMGImageRequest imageWithID:@"fdsfdsfdsa" success:^(IMGImage *image) {
        
        //should not success
        failBlock([NSError errorWithDomain:IMGErrorDomain code:0 userInfo:nil]);
        
    } failure:^(NSError *error) {
        
        //imgur sometimes responds with previous account requests for some reasons saying it is a cache hit even though it is a different URL
        //in this case this test will fail with code 1 == IMGErrorResponseMissingParameters
        
        expect(error.code == 404).beTruthy();
        expect([error.userInfo[IMGErrorServerMethod] isEqualToString:@"GET"]).beTruthy();
        
        //should go here
        isSuccess = YES;
        
    }];
    
    expect(isSuccess).will.beTruthy();
}


// no longer working since POST does not retry authentications

- (void)testPostAndDeleteGalleryImage{
    
    __block BOOL isDeleted;
    
    [self postTestGalleryImage:^(IMGGalleryImage * image, void(^success)()) {
        
        success();
        isDeleted = YES;
    }];
    
    expect(isDeleted).will.beTruthy();
}

- (void)testPostAndDeleteGalleryAlbum{
    
    __block BOOL isDeleted;
    [self postTestGalleryAlbumWithOneImage:^(IMGGalleryAlbum * album, void(^success)()) {
        
        success();
        isDeleted = YES;
    }];
    expect(isDeleted).will.beTruthy();
}

- (void)testPostAndDeleteImage{
    
    __block BOOL isDeleted;
    [self postTestImage:^(IMGImage * image, void(^success)()) {
        
        success();
        isDeleted = YES;
    }];
    expect(isDeleted).will.beTruthy();
}

- (void)testPostAndDeleteAlbum{
    
    __block BOOL isDeleted;
    [self postTestAlbumWithOneImage:^(IMGAlbum * album, void(^success)()) {
        
        success();
        isDeleted = YES;
    }];
    expect(isDeleted).will.beTruthy();
}

@end
