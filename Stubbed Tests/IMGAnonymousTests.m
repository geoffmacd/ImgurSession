//
//  IMGAnonymousTests.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-21.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

//add read-write prop
@interface IMGSession (TestSession)

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;

@end


@interface IMGTestCase (Anon)

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;

@end

@implementation IMGTestCase (Anon)

-(void)setUp{
    [super setUp];
    //run before each test
    
    //5 second timeout
    [Expecta setAsynchronousTestTimeout:5.0];
    
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    
    //dummy auth session
    [IMGSession anonymousSessionWithClientID:@"dfsfds" withDelegate:self];
    
    //no reachability for offline tests
    [[IMGSession sharedInstance] setImgurReachability:nil];
    
    //need various values such as image title
    imgurUnitTestParams = infos[@"imgurUnitTestParams"];
    
    //failure block
    failBlock = ^(NSError * error) {
        
        NSLog(@"Error : %@", [error localizedDescription]);
        
        XCTAssert(nil, @"FAIL");
    };
}


@end



@interface IMGAnonymousTests : IMGTestCase

@end


@implementation IMGAnonymousTests

- (void)testGalleryWithBadClientAuthentication{
    
    __block BOOL isSuccess;
    
    [self stubWithFile:@"badhotgalleryrequest-noauthenticiation.json" withStatusCode:403];
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        //should not be successful
        expect(0).beTruthy();
        
        isSuccess = YES;
        
    } failure:^(NSError * error) {
        
        expect([error.domain isEqualToString:AFNetworkingErrorDomain]);
        
        isSuccess = YES;
    }];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryHot{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"hotgalleryanon.json"];
    
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray * images) {
        
        
        expect(images).haveCountOf(183);
        
        IMGGalleryAlbum * album = images[2];
        IMGGalleryImage * image = images[0];
        
        expect(album.albumID).beTruthy();
        expect(album.views).beTruthy();
        expect(album.ups).beTruthy();
        
        expect(image.imageID).beTruthy();
        expect(image.views).beTruthy();
        expect(image.ups).beTruthy();
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryViral{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"topgalleryanon.json"];
    
    [IMGGalleryRequest topGalleryPage:0 withWindow:IMGTopGalleryWindowDay success:^(NSArray * images) {
        
        expect(images).haveCountOf(183);
        
        IMGGalleryAlbum * album = images[2];
        IMGGalleryImage * image = images[0];
        
        expect(album.albumID).beTruthy();
        expect(album.views).beTruthy();
        expect(album.ups).beTruthy();
        
        expect(image.imageID).beTruthy();
        expect(image.views).beTruthy();
        expect(image.ups).beTruthy();
        
        //test copy
        IMGGalleryAlbum * copy = [album copy];
        expect(album.albumID).equal(copy.albumID);
        expect(album.albumDescription).equal(copy.albumDescription);
        expect(album).equal(copy);
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(album.albumID).equal(copy.albumID);
        expect(album.albumDescription).equal(copy.albumDescription);
        expect(album).equal(copy);
        
        //test copy
        IMGGalleryImage * copyImage = [image copy];
        expect(image.imageID).equal(copyImage.imageID);
        expect(image.title).equal(copyImage.title);
        expect(image.ups).equal(copyImage.ups);
        expect(image.accountURL).equal(copyImage.accountURL);
        expect(image).equal(copyImage);
        
        data = [NSKeyedArchiver archivedDataWithRootObject:copyImage];
        copyImage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(image.imageID).equal(copyImage.imageID);
        expect(image.title).equal(copyImage.title);
        expect(image.ups).equal(copyImage.ups);
        expect(image.accountURL).equal(copyImage.accountURL);
        expect(image).equal(copyImage);
        
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryUser{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"usersubgalleryanon.json"];
    
    [IMGGalleryRequest userGalleryPage:0 withViralSort:YES showViral:YES success:^(NSArray * images) {
        
        expect(images).haveCountOf(183);
        
        IMGGalleryAlbum * album = images[2];
        IMGGalleryImage * image = images[0];
        
        expect(album.albumID).beTruthy();
        expect(album.views).beTruthy();
        expect(album.ups).beTruthy();
        
        expect(image.imageID).beTruthy();
        expect(image.views).beTruthy();
        expect(image.ups).beTruthy();
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testGalleryImage{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"galleryimage.json"];
    
    [IMGGalleryRequest imageWithID:@"mOqejNf" success:^(IMGGalleryImage *image) {
        
        expect(image.imageID).beTruthy();
        
        //test copy
        IMGGalleryImage * copy = [image copy];
        expect(image.imageID).equal(copy.imageID);
        expect(image.title).equal(copy.title);
        expect(image.ups).equal(copy.ups);
        expect(image.accountURL).equal(copy.accountURL);
        expect(image).equal(copy);
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(image.imageID).equal(copy.imageID);
        expect(image.title).equal(copy.title);
        expect(image.ups).equal(copy.ups);
        expect(image.accountURL).equal(copy.accountURL);
        expect(image).equal(copy);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testImage{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"image.json"];
    
    [IMGImageRequest imageWithID:@"mOqejNf" success:^(IMGImage *image) {
        
        expect(image.imageID).beTruthy();
        
        //test copy
        IMGImage * copy = [image copy];
        expect(image.imageID).equal(copy.imageID);
        expect(image.title).equal(copy.title);
        expect(image).equal(copy);
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(image.imageID).equal(copy.imageID);
        expect(image.title).equal(copy.title);
        expect(image).equal(copy);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


- (void)testGalleryAlbum{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"galleryalbum.json"];
    
    [IMGGalleryRequest albumWithID:@"HtAOg" success:^(IMGGalleryAlbum *album) {
        
        expect(album.albumID).beTruthy();
        
        //test copy
        IMGGalleryAlbum * copy = [album copy];
        expect(album.albumID).equal(copy.albumID);
        expect(album.albumDescription).equal(copy.albumDescription);
        expect(album).equal(copy);
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(album.albumID).equal(copy.albumID);
        expect(album.albumDescription).equal(copy.albumDescription);
        expect(album).equal(copy);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAlbum{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"album.json"];
    
    [IMGAlbumRequest albumWithID:@"HtAOg" success:^(IMGAlbum *album) {
        
        expect(album.albumID).beTruthy();
        
        //test copy
        IMGAlbum * copy = [album copy];
        expect(album.albumID).equal(copy.albumID);
        expect(album.albumDescription).equal(copy.albumDescription);
        expect(album).equal(copy);
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(album.albumID).equal(copy.albumID);
        expect(album.albumDescription).equal(copy.albumDescription);
        expect(album).equal(copy);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testUsersAccount{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"geoffsaccount.json"];
    
    [IMGAccountRequest accountWithUser:imgurUnitTestParams[@"recipientId"]  success:^(IMGAccount *account) {
        
        expect(account.accountID).beTruthy();
        expect(account.username).beTruthy();
        
        //test copy
        IMGAccount * copy = [account copy];
        expect(account.accountID).equal(copy.accountID);
        expect(account.username).equal(copy.username);
        expect(account).equal(copy);
        
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:copy];
        copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        expect(account.accountID).equal(copy.accountID);
        expect(account.username).equal(copy.username);
        expect(account).equal(copy);
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testUsersComments{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"geoffscomments.json"];
    
    [IMGAccountRequest accountCommentsWithUser:imgurUnitTestParams[@"recipientId"] success:^(NSArray * comments) {
        
        expect(comments).haveCountOf(1);
        
        IMGComment * first = [comments firstObject];
        expect(first.commentID).beTruthy();
        expect(first.caption).beTruthy();
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testUsersCommentWithID{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"mycommentwithid.json"];
    
    [IMGAccountRequest accountCommentWithID:15325 success:^(IMGComment * firstComment) {
        
        expect(firstComment.caption).beTruthy();
        expect(firstComment.galleryID).beTruthy();
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}


@end
