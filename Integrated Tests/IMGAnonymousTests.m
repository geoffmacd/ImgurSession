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

//add read-write prop
@interface IMGSession (TestSession)

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;

@end

@implementation IMGAnonymousTests

- (void)testGalleryWithBadClientAuthentication{
    
    __block BOOL isSuccess;
    
    //client id is all that necessary for this header
    [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
    
    [IMGGalleryRequest albumWithID:@"HtAOg" success:^(IMGGalleryAlbum *album) {
        
        //fail, should not attempt refresh
        expect(0).beTruthy();
        
        isSuccess = YES;
        
    } failure:^(NSError * error) {
        
        expect(error.code == IMGErrorForbidden).beTruthy();
        expect([error.userInfo[IMGErrorServerMethod] isEqualToString:@"GET"]).beTruthy();
        expect([error.userInfo[IMGErrorServerPath] isEqualToString:@"/3/gallery/album/HtAOg"]).beTruthy();
        expect([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"Invalid client_id"]).beTruthy();
        isSuccess = YES;
    }];

    expect(isSuccess).will.beTruthy();
    
    //fix for next test
    [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@",
                                                             [IMGSession sharedInstance].clientID] forHTTPHeaderField:@"Authorization"];
}

- (void)testGalleryHot{
    
    __block BOOL isSuccess;
    __block NSMutableOrderedSet * j = [NSMutableOrderedSet new];
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    
    [IMGGalleryRequest hotGalleryPage:1 success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [IMGGalleryRequest hotGalleryPage:2 success:^(NSArray * images) {
            
            [j addObjectsFromArray:images];
            
            if(j.count == images.count)
                failBlock(nil);
            else
                isSuccess = YES;
            
        } failure:failBlock];
    });
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryTop{
    
    __block BOOL isSuccess;
    __block NSMutableOrderedSet * j = [NSMutableOrderedSet new];
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    
    [IMGGalleryRequest topGalleryPage:1 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [IMGGalleryRequest topGalleryPage:2 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
            
            [j addObjectsFromArray:images];
            
            if(j.count == images.count)
                failBlock(nil);
            else
                isSuccess = YES;
            
        } failure:failBlock];
    });
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryUser{
    
    __block BOOL isSuccess;
    __block NSMutableOrderedSet * j = [NSMutableOrderedSet new];
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    [IMGGalleryRequest userGalleryPage:1 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        [j addObjectsFromArray:images];
        
    } failure:failBlock];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [IMGGalleryRequest userGalleryPage:2 withViralSort:YES showViral:YES success:^(NSArray * images) {
            
            [j addObjectsFromArray:images];
            
            if(j.count == images.count)
                failBlock(nil);
            else
                isSuccess = YES;
            
        } failure:failBlock];
    });
    
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

- (void)testPostAnonymousImage{
    
    __block BOOL isSuccess;
    __block BOOL progressTested;
    
    NSData * data = [NSData dataWithContentsOfURL:testfileURL];
    
    [IMGImageRequest uploadImageWithData:data title:@"random test image of kitties" success:^(IMGImage *image) {
        
        expect(image.imageID).beTruthy();
        isSuccess = YES;
    } progress:nil failure:failBlock];
    
    expect(progressTested).will.beTruthy();
    expect(isSuccess).will.beTruthy();
}

- (void)testPostAnonymousGif{
    
    __block BOOL isSuccess;
    NSProgress * progress;
    
    NSData * data = [NSData dataWithContentsOfURL:testGifURL];
    
    [IMGImageRequest uploadImageWithGifData:data title:@"Stupid top post" success:^(IMGImage * image) {
        
        expect(image.imageID).beTruthy();
        isSuccess = YES;
        
    } progress:&progress failure:failBlock];
    
    expect(progress.fractionCompleted >= 1.0).will.beTruthy();
    expect(isSuccess).will.beTruthy();
}

- (void)testPostThenDeleteAnonymousAlbum{
    
    __block BOOL isSuccess;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL success:^(IMGImage *image) {
        
        expect(image.imageID).beTruthy();
        
        [IMGAlbumRequest createAlbumWithTitle:@"Test kitty" description:@"blah" imageIDs:@[image.imageID] privacy:IMGAlbumPublic layout:IMGBlogLayout cover:image.imageID success:^(NSString * albumID, NSString * deletehash) {

            expect(albumID).beTruthy();
            
            [IMGAlbumRequest deleteAlbumWithDeleteHash:deletehash success:^{
                
                
                isSuccess = YES;
                
            } failure:failBlock];
        } failure:failBlock];
    } progress:nil failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testPostAnonymousImages{
    
    __block BOOL isSuccess;
    
    NSArray * files = @[@{@"fileURL":testfileURL,@"title":@"kitties", @"description":@""},
                        @{@"fileURL":testfileURL,@"title":@"kitties 2", @"description":@""}
                        ];
    
    [IMGImageRequest uploadImages:files success:^(NSArray *array) {
        
        IMGImage * image = [array firstObject];
        expect(image.imageID).beTruthy();
        isSuccess = YES;
        
    } progress:nil failure:failBlock];
    
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

- (void)testGalleryObject{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest objectWithID:@"HtAOg" success:^(id<IMGGalleryObjectProtocol> object) {
        
        expect(object.isAlbum).beTruthy();
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
        
        expect(comments.count).beGreaterThan(0);
        IMGComment * first = [comments firstObject];
        expect(first.commentID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryComments{
    
    __block BOOL isSuccess;
    
    [IMGGalleryRequest commentsWithGalleryID:@"1I5nqe0" withSort:IMGGalleryCommentSortBest success:^(NSArray * comments) {
        
        IMGComment * first = [comments firstObject];
        expect(first.commentID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testCommentReplies{
    
    __block BOOL isSuccess;
    
    [IMGCommentRequest repliesWithCommentID:205050082 success:^(NSArray * comments) {
        
        IMGComment * first = [comments firstObject];
        expect(first.commentID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testMemes{
    
    __block BOOL isSuccess;
    [IMGMemeGen defaultMemes:^(NSArray *memeImages) {
        
        IMGImage * first = [memeImages firstObject];
        expect(first.imageID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

@end
