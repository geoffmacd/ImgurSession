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
    
    __block BOOL isSuccess;
    [self stubWithFile:@"hotgallery.json"];
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        expect(images).haveCountOf(185);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryViral{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"topgallery.json"];
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
        
        expect(images).haveCountOf(185);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryUser{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"usersubmittedgallery.json"];
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        expect(images).haveCountOf(185);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


@end
