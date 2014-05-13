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
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay withViralSort:YES success:^(NSArray * images) {
        
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

@end
