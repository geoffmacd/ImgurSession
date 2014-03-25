//
//  IMGAnonymousTests.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-21.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

@interface IMGAnonymousTests : IMGTestCase

@end


@implementation IMGAnonymousTests

- (void)testGalleryHot{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"hotgalleryanon.json"];
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryViral{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"topgalleryanon.json"];
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay withViralSort:YES success:^(NSArray * images) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryUser{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"usersubgalleryanon.json"];
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryImage{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"galleryimage.json"];
    
    [IMGGalleryRequest imageWithID:@"mOqejNf" success:^(IMGGalleryImage *image) {
        
        expect(image.imageID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testImage{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"image.json"];
    
    [IMGImageRequest imageWithID:@"mOqejNf" success:^(IMGImage *image) {
        
        expect(image.imageID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


- (void)testGalleryAlbum{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"galleryalbum.json"];
    
    [IMGGalleryRequest albumWithID:@"HtAOg" success:^(IMGGalleryAlbum *album) {
        
        expect(album.albumID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAlbum{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"album.json"];
    
    [IMGAlbumRequest albumWithID:@"HtAOg" success:^(IMGAlbum *album) {
        
        expect(album.albumID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testUsersAccount{
    
    __block IMGAccount * acc;
    [self stubWithFile:@"geoffsaccount.json"];
    
    [IMGAccountRequest accountWithUser:imgurUnitTestParams[@"recipientId"]  success:^(IMGAccount *account) {
        
        expect(account.bio).beTruthy();
        expect(account.accountID).beTruthy();
        expect(account.username).beTruthy();
        acc = account;
        
    } failure:failBlock];
    
    expect(acc).willNot.beNil();
}

- (void)testUsersComments{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"geoffscomments.json"];
    
    [IMGAccountRequest accountCommentsWithUser:imgurUnitTestParams[@"recipientId"] success:^(NSArray * comments) {
        
        expect(comments).haveCountOf(1);
        IMGComment * first = [comments firstObject];
        expect(first.commentId).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

@end
