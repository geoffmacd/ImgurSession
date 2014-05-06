//
//  ImgurSession_Tests.m
//  ImgurSession Tests
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGIntegratedTestCase.h"

#warning: Tests requires client id, client secret filled out in tests plist
#warning: Tests must have refresh token filled out in tests plist in order to work on iPhone


@interface IMGAccountTests : IMGIntegratedTestCase

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

- (void)testAccountEmailIsVerified{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest isUserEmailVerification:^(BOOL verified) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountLoadMyFavs{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountFavourites:^(NSArray * favorites) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountLoadMySubmissions{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountSubmissionsWithUser:imgurUnitTestParams[@"recipientId"] withPage:0 success:^(NSArray * submissions) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
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
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountUnreadReplies:^(NSArray * replies) {

        [IMGAccountRequest accountAllReplies:^(NSArray * oldReplies) {
        
            isSuccess = YES;

        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountComments{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountCommentIDsWithUser:@"me" success:^(NSArray * commentIds) {

        if([commentIds firstObject]){
            [IMGAccountRequest accountCommentWithID:[[commentIds firstObject] integerValue] success:^(IMGComment * firstComment) {

                [IMGAccountRequest accountCommentsWithUser:@"me" success:^(NSArray * comments) {
                    
                    [IMGAccountRequest accountCommentCount:@"me" success:^(NSInteger numcomments) {

                        expect([comments count] == numcomments ).to.beTruthy();
                        isSuccess = YES;

                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountImages{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountImageIDsWithUser:@"me" success:^(NSArray * images) {
        
        if([images firstObject]){
            [IMGAccountRequest accountImageWithID:[images firstObject] success:^(IMGImage * image) {
                
                [IMGAccountRequest accountImagesWithUser:@"me" withPage:0 success:^(NSArray * images) {
                        
                    [IMGAccountRequest accountImageCount:@"me" success:^(NSInteger num) {
                        
                        isSuccess = YES;
                        
                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountAlbums{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountAlbumIDsWithUser:@"me" success:^(NSArray * albums) {
        
        if([albums firstObject]){
            [IMGAccountRequest accountAlbumWithID:[albums firstObject] success:^(IMGAlbum * album) {
                
                [IMGAccountRequest accountAlbumsWithUser:@"me" withPage:0 success:^(NSArray * albums) {
                    
                    [IMGAccountRequest accountAlbumCountWithUser:@"me" success:^(NSInteger num) {
                        
                        isSuccess = YES;
                        
                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testAccountCommentDelete{
    
    __block BOOL isDeleted;
    
    [self postTestImage:^(IMGImage * image, void(^success)()) {
        
        
        [IMGCommentRequest submitComment:@"test comment" withImageID:image.imageID success:^(NSInteger commentId) {
                
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

        [IMGAccountRequest accountDeleteAlbumWithID:image.deletehash success:^() {
            
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
