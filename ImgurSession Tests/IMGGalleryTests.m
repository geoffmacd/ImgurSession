//
//  IMGGalleryTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-19.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

@interface IMGGalleryTests : IMGTestCase

@end

@implementation IMGGalleryTests

- (void)testGalleryHot{
    
    __block NSArray * gals;
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        gals = images;
        
    } failure:failBlock];
    
    expect(gals).willNot.beNil();
}

- (void)testGalleryViral{
    
    __block NSArray * gals;
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay withViralSort:YES success:^(NSArray * images) {
        
        gals = images;
        
    } failure:failBlock];
    
    expect(gals).willNot.beNil();
}

- (void)testGalleryUser{
    
    __block NSArray * gals;
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        gals = images;
        
    } failure:failBlock];
    
    expect(gals).willNot.beNil();
}

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
