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
    
    [self postTestGalleryImage:nil];
}

- (void)testPostAndDeleteGalleryAlbum{
    
    [self postTestGalleryAlbumWithOneImage:nil];
}

- (void)testPostAndDeleteImage{
    
    [self postTestImage:nil];
}

- (void)testPostAndDeleteAlbum{
    
    [self postTestAlbumWithOneImage:nil];
}

@end
