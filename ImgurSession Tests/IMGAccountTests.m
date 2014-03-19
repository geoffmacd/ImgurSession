//
//  ImgurSession_Tests.m
//  ImgurSession Tests
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

#warning: Implementation requires client id, client secret filled out in tests plist
#warning: imgur user must have refresh token filled out in tests plist in order to work on iPhone
#warning: Imgur users must have favourites gallery items, gallery posts , and comments posted to the gallery
#warning: delegate methods not called unless dispatch methods are overwritten due to strange run loop in test runs, may need to call directly

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

    } failure:failBlock];
    
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

        [IMGAccountRequest accountRepliesWithFresh:NO success:^(NSArray * freshReplies) {

            //should have less fresh replies
            expect(freshReplies).to.beLessThanOrEqualTo(replies);

        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(rep).willNot.beNil();
}

- (void)testAccountComments{
    
    __block NSArray * com;
    
    [IMGAccountRequest accountCommentIDsWithUser:@"me" success:^(NSArray * commentIds) {

        [IMGAccountRequest accountCommentWithID:[commentIds firstObject] success:^(IMGComment * firstComment) {

            [IMGAccountRequest accountCommentsWithUser:@"me" success:^(NSArray * comments) {
                
                com = comments;
                expect([comments count] == [commentIds count]).to.beTruthy();

                [IMGAccountRequest accountCommentCount:@"me" success:^(NSUInteger numcomments) {

                    
                    expect([comments count] == numcomments ).to.beTruthy();

                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];

    expect(com).willNot.beNil();
}

/**
 Posts image to comment on, comments on it, replies to comment, then deletes everything
 */
- (void)testCommentReplyAndDelete{
    
    __block BOOL deleteSuccess = NO;
    
    [self postTestImage:^(IMGImage * image, void(^success)()){
        
        success();
        [IMGCommentRequest submitComment:@"test comment" withImageID:image.imageID withParentID:0 success:^(IMGComment * comment) {
            
            [IMGCommentRequest replyToComment:@"test reply" withImageID:image.imageID withCommentID:comment.commentId success:^(IMGComment * reply) {
                
                expect(reply.parentId == comment.commentId).beTruthy();
                
                [IMGCommentRequest deleteCommentWithID:reply.commentId success:^() {
                    
                    [IMGCommentRequest deleteCommentWithID:reply.commentId success:^() {
                        
                        deleteSuccess = YES;
                        
                    } failure:failBlock];
                    
                } failure:failBlock];
                
            } failure:failBlock];
            
        } failure:failBlock];
        
    }];
    
    expect(deleteSuccess).will.beTruthy();
}

//
//- (void)testAccountImages{
//    
//    [IMGAccountRequest accountImageIds:@"me" success:^(NSArray * images) {
//        
//        [IMGAccountRequest accountImageWithId:[images firstObject] success:^(IMGImage * image) {
//            
//            [IMGAccountRequest accountImagesWithUsername:@"me" withPage:0 success:^(NSArray * images) {
//                
//                [IMGAccountRequest accountImageCount:@"me" success:^(NSNumber * numImages) {
//                    
//                    
//                } failure:failBlock];
//            } failure:failBlock];
//        } failure:failBlock];
//    } failure:failBlock];
//}
//
//- (void)testAccountAlbums{
//    
//    [IMGAccountRequest accountAlbumIds:@"me" success:^(NSArray * albums) {
//        
//        [IMGAccountRequest accountAlbumWithId:[albums firstObject] success:^(IMGAlbum * album) {
//            
//            [IMGAccountRequest accountAlbumsWithUsername:@"me" withPage:0 success:^(NSArray * albums) {
//                
//                //always returns 502??
//                [IMGAccountRequest accountAlbumCount:@"me" success:^(NSNumber * numAlbums) {
//                    
//                    
//                } failure:failBlock];
//            } failure:failBlock];
//        } failure:failBlock];
//    } failure:failBlock];
//}


@end
