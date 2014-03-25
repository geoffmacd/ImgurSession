//
//  IMGAnonymousTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-25.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGIntegratedTestCase.h"

@interface IMGAnonymousTests : IMGIntegratedTestCase

@end


@implementation IMGAnonymousTests

- (void)testGalleryHot{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryViral{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay withViralSort:YES success:^(NSArray * images) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryUser{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryImage{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest imageWithID:@"mOqejNf" success:^(IMGGalleryImage *image) {
        
        expect(image.imageID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testImage{
    
    __block BOOL isSuccess;
    
    [IMGImageRequest imageWithID:@"mOqejNf" success:^(IMGImage *image) {
        
        expect(image.imageID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


- (void)testGalleryAlbum{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest albumWithID:@"HtAOg" success:^(IMGGalleryAlbum *album) {
        
        expect(album.albumID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAlbum{
    
    __block BOOL isSuccess;
    
    [IMGAlbumRequest albumWithID:@"HtAOg" success:^(IMGAlbum *album) {
        
        expect(album.albumID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testUsersAccount{
    
    __block IMGAccount * acc;
    
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
    
    [IMGAccountRequest accountCommentsWithUser:imgurUnitTestParams[@"recipientId"] success:^(NSArray * comments) {
        
        expect(comments).haveCountOf(1);
        IMGComment * first = [comments firstObject];
        expect(first.commentId).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

@end
