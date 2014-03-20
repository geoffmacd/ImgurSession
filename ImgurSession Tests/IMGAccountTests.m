//
//  ImgurSession_Tests.m
//  ImgurSession Tests
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

#warning: Tests requires client id, client secret filled out in tests plist
#warning: Tests must have refresh token filled out in tests plist in order to work on iPhone
#warning: Test user must have at least: one notification, one comment, one image post, one favourtie


@interface IMGAccountTests : IMGTestCase

@end

@implementation IMGAccountTests

#pragma mark - Test Account endpoints


- (void)testAccountLoadMe{
    
    __block IMGAccount * acc;
    
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        acc = account;
        
    } failure:failBlock];
    
    expect(acc).willNot.beNil();
}

- (void)testAccountLoadMyFavs{
    
    __block NSArray * favs;
    
    [IMGAccountRequest accountFavouritesWithSuccess:^(NSArray * favorites) {
        
        favs = favorites;
        
    } failure:failBlock];
    
    expect(favs).willNot.beNil();
}

- (void)testAccountLoadMySubmissions{
    
    __block NSArray * subs;
    
    [IMGAccountRequest accountSubmissionsWithUser:@"me" withPage:0 success:^(NSArray * submissions) {
        
        subs = submissions;
        
    } failure:failBlock];
    
    expect(subs).willNot.beNil();
}

- (void)testAccountSettingsLoad{
    
    __block IMGAccountSettings *set;
    
    [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
        
        set = settings;

    } failure: failBlock];
    
    expect(set).willNot.beNil();
}

- (void)testAccountSettingsChange{
    
    __block IMGAccountSettings *set;
    
    [IMGAccountRequest changeAccountWithBio:@"test bio" messagingEnabled:YES publicImages:YES albumPrivacy:IMGAlbumPublic acceptedGalleryTerms:YES success:^{
        
        [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
            
            
            [IMGAccountRequest changeAccountWithBio:@"test bio 2" success:^{
                
                [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
                    
                    set = settings;
                    
                } failure:failBlock];
                
            } failure:failBlock];
            
        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(set).willNot.beNil();
}

- (void)testAccountReplies{
    
    __block NSArray * rep;
    
    [IMGAccountRequest accountReplies:^(NSArray * replies) {

        [IMGAccountRequest accountRepliesWithFresh:NO success:^(NSArray * oldReplies) {
            
            rep = oldReplies;

        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(rep).willNot.beNil();
}

- (void)testAccountComments{
    
    __block NSArray * com;
    
    [IMGAccountRequest accountCommentIDsWithUser:@"me" success:^(NSArray * commentIds) {

        [IMGAccountRequest accountCommentWithID:[[commentIds firstObject] integerValue] success:^(IMGComment * firstComment) {

            [IMGAccountRequest accountCommentsWithUser:@"me" success:^(NSArray * comments) {
                
                com = comments;

                [IMGAccountRequest accountCommentCount:@"me" success:^(NSUInteger numcomments) {

                    
                    expect([comments count] == numcomments ).to.beTruthy();

                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];

    expect(com).willNot.beNil();
}

- (void)testAccountImages{
    
    __block NSUInteger numImages = 0;
    
    [IMGAccountRequest accountImageIDsWithUser:@"me" success:^(NSArray * images) {
        
        [IMGAccountRequest accountImageWithID:[images firstObject] success:^(IMGImage * image) {
            
            [IMGAccountRequest accountImagesWithUser:@"me" withPage:0 success:^(NSArray * images) {
                    
                [IMGAccountRequest accountImageCount:@"me" success:^(NSUInteger num) {
                    
                    numImages = num;
                    
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    expect(numImages).will.beGreaterThan(0);
}

- (void)testAccountAlbums{
    
    __block NSUInteger numAlbums = 0;
    
    [IMGAccountRequest accountAlbumIDsWithUser:@"me" success:^(NSArray * albums) {
        
        [IMGAccountRequest accountAlbumWithID:[albums firstObject] success:^(IMGAlbum * album) {
            
            [IMGAccountRequest accountAlbumsWithUser:@"me" withPage:0 success:^(NSArray * albums) {
                
                //always returns 502??
                [IMGAccountRequest accountAlbumCountWithUser:@"me" success:^(NSUInteger num) {
                    
                    numAlbums = num;
                    
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    expect(numAlbums).will.beGreaterThan(0);
}

-(void)testAccountCommentDelete{
    
    __block BOOL isDeleted;
    [self postTestImage:^(IMGImage * image, void(^success)()) {
        
        
        [IMGCommentRequest submitComment:@"test comment" withImageID:image.imageID withParentID:0 success:^(NSUInteger commentId) {
                
            [IMGAccountRequest accountDeleteCommentWithID:commentId success:^{
                
                success();
                isDeleted = YES;
                
            } failure:failBlock];
            
        } failure:failBlock];
    }];
    
    expect(isDeleted).will.beTruthy();
}

-(void)testAccountImageDelete{
    
    __block BOOL isDeleted;
    [self postTestImage:^(IMGImage * image, void(^success)()) {

        [IMGAccountRequest accountDeleteImageWithHash:image.deletehash success:^() {
            
            success();
            isDeleted = YES;
    
        } failure:failBlock];
    }];
    
    expect(isDeleted).will.beTruthy();
}

-(void)testAccountAlbumDelete{
    
    __block BOOL isDeleted;
    [self postTestAlbumWithOneImage:^(IMGAlbum * album, void(^success)()) {
        
        [IMGAccountRequest accountDeleteAlbumWithID:album.albumID success:^{
            
            success();
            isDeleted = YES;
            
        } failure:failBlock];
    }];
    
    expect(isDeleted).will.beTruthy();
}

@end
