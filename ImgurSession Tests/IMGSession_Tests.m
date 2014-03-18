//
//  ImgurSession_Tests.m
//  ImgurSession Tests
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

#import "IMGImage.h"
#import "IMGGalleryImage.h"
#import "IMGAccountSettings.h"

#define kTestTimeOut     30     //seconds

#warning: Implementation requires client id, client secret filled out in tests plist
#warning: imgur user must have refresh token filled out in tests plist in order to work on iPhone
#warning: Imgur users must have favourites gallery items, gallery posts , and comments posted to the gallery
#warning: delegate methods not called unless dispatch methods are overwritten due to strange run loop in test runs, may need to call directly

@interface IMGSession_Tests : IMGTestCase{
}
@end

@implementation IMGSession_Tests

#pragma mark - Test Account endpoints

- (void)testAccountLoadMe{
    
    __block IMGAccount * acc;
    
    [IMGAccountRequest accountWithUsername:@"me" success:^(IMGAccount *account) {
        
        acc = account;
        
    } failure:failBlock];
    
    expect(acc).willNot.beNil();
}

- (void)testAccountLoadMyFavs{
    
    __block NSArray * favs;
    
    [IMGAccountRequest accountFavourites:@"me" success:^(NSArray * favorites) {
        
        favs = favorites;
        
    } failure:failBlock];
    
    expect(favs).willNot.beNil();
}

- (void)testAccountLoadMySubmissions{
    
    __block NSArray * subs;
    
    [IMGAccountRequest accountSubmissionsPage:0 withUsername:@"me" success:^(NSArray * submissions) {
        
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
//
//- (void)testAccountItems{
//
//    [IMGAccountRequest accountGalleryFavourites:@"me" success:^(NSArray * gallery) {
//        
//        [IMGAccountRequest accountFavourites:@"me" success:^(NSArray * favourites) {
//            
//            [IMGAccountRequest accountSubmissionsPage:0 withUsername:@"me" success:^(NSArray * submissions) {
//                
//                [IMGAccountRequest accountReplies:^(NSArray * replies) {
//                    
//                    [IMGAccountRequest accountRepliesWithFresh:NO success:^(NSArray * replies) {
//                        
//                        
//                    } failure:failBlock];
//                    
//                } failure:failBlock];
//            } failure:failBlock];
//        } failure:failBlock];
//    } failure:failBlock];
//
//}
//
//- (void)testAccountComments{
//    
//    [IMGAccountRequest accountCommentIds:@"me" success:^(NSArray * comments) {
//        
//        [IMGAccountRequest accountCommentWithId:[comments firstObject] success:^(IMGComment * comment) {
//            
//            [IMGAccountRequest accountCommentsWithUsername:@"me" success:^(NSArray * comments) {
//                
//                [IMGAccountRequest accountCommentCount:@"me" success:^(NSNumber * numcomments) {
//                    
//                    
//                    
//                } failure:failBlock];
//            } failure:failBlock];
//        } failure:failBlock];
//    } failure:failBlock];
//
//}
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
//
//#pragma mark - Test Album endpoints
//
///*
// Tests creating, submitting publicly, getting, removing from public and deleting album
// **/
//- (void)testAlbumWorkflowAsync{
//
//}
//
//#pragma mark - Test Image endpoints
//
///*
// Tests uploading image, submission process, removal and deletion of individual images
// **/
//- (void)testImageWorkflowAsync{
//    
//    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
//}
//
//#pragma mark - Test Gallery endpoints
//
///*
// Testing pulling the gallerys
// **/
//- (void)testGallery{
//    
//    //default gallery
//    [IMGGalleryRequest galleryWithParameters:nil success:^(NSArray * images) {
//        
//        [IMGGalleryRequest hotGalleryPage:0 withViralSort:NO success:^(NSArray * images) {
//            
//            [IMGGalleryRequest hotGalleryPage:0 withViralSort:YES success:^(NSArray * images) {
//            
//                [IMGGalleryRequest hotGalleryPage:2 withViralSort:YES success:^(NSArray * images) {
//                    
//                    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay withViralSort:YES success:^(NSArray * images) {
//                        
//                        [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowAll withViralSort:NO success:^(NSArray * images) {
//                            
//                            [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowMonth withViralSort:NO success:^(NSArray * images) {
//                                
//                                [IMGGalleryRequest userGalleryPage:0 withViralSort:NO showViral:NO success:^(NSArray * images) {
//                                    
//                                    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
//                                        
//                                        
//                                    } failure:failBlock];
//                                    
//                                } failure:failBlock];
//                                
//                            } failure:failBlock];
//                            
//                        } failure:failBlock];
//                        
//                    } failure:failBlock];
//                    
//                } failure:failBlock];
//                
//            } failure:failBlock];
//            
//        } failure:failBlock];
//        
//    } failure:failBlock];
//}
//
///*
// Testing gallery comments
// **/
//- (void)testGallerySubmitandComment{
//    
//    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
//    
//    //default gallery
//    [IMGImageRequest uploadImageWithFileURL:fileURL success:^(IMGImage *image) {
//        
//        [IMGGalleryRequest submitImageWithID:image.imageID title:@"Geoff Test" success:^() {
//            
//            [IMGGalleryRequest commentsWithGalleryID:image.imageID withSort:IMGGalleryCommentSortBest success:^(NSArray * comments) {
//                
//                
//                
//            } failure:failBlock];
//            
//        } failure:failBlock];
//        
//    } failure:failBlock];
//    
//}



@end
