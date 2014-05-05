//
//  IMGTestCase.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-18.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGIntegratedTestCase.h"


//add read-write prop
@interface IMGSession (TestSession)

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;


-(void)setAnonmyousAuthenticationWithID:(NSString*)clientID;

@end



@implementation IMGIntegratedTestCase

- (void)setUp {
    [super setUp];
    //run before each test
    
    //30 second timeout
    [Expecta setAsynchronousTestTimeout:500.0];
    
        
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    //need various values such as image title
    imgurUnitTestParams = infos[@"imgurUnitTestParams"];
    
    // Initializing the client
    NSDictionary *imgurClient = infos[@"imgurClientCredentials"];
    NSString *clientID = imgurClient[@"id"];
    NSString *clientSecret = imgurClient[@"secret"];
    anon = [imgurClient[@"anonymous"] boolValue];
    
    if(anon){
        [IMGSession anonymousSessionWithClientID:clientID withDelegate:self];
        [[IMGSession sharedInstance] securityPolicy].allowInvalidCertificates = YES;
    } else {
        //Lazy init, may already exist
        IMGSession * ses = [IMGSession authenticatedSessionWithClientID:clientID secret:clientSecret authType:IMGPinAuth withDelegate:self];
        [[IMGSession sharedInstance] securityPolicy].allowInvalidCertificates = YES;
        if([imgurClient[@"refreshToken"] length])
            ses.refreshToken = imgurClient[@"refreshToken"];
    }
    
    //failure block
    failBlock = ^(NSError * error) {
        
        NSLog(@"Error : %@", [error localizedDescription]);
        XCTAssert(nil, @"FAIL");
    };
    
    testfileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
    testGifURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:@"gif"]];
    
    //Ensure client data is avaialble for authentication to proceed
    XCTAssertTrue(clientID, @"Client ID is missing");
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Test methods to provide image or album to play with - this code is not infallable

#warning Posting a test gallery image will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post gallery image for testing - This is dangerous
 */
-(void)postTestGalleryImage:(void(^)(IMGGalleryImage *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:imgurUnitTestParams[@"title"] description:@"Test Description" linkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        [IMGGalleryRequest submitImageWithID:image.imageID title:@"Test Gallery" terms:YES success:^() {
            
            [IMGGalleryRequest imageWithID:image.imageID success:^(IMGGalleryImage *galImage) {
                
                if(success)
                    success(galImage, ^{
                        
                        //remove from gallery and delete image
                        [IMGGalleryRequest removeImageWithID:image.imageID success:^(NSString *albumID) {
                            
                            [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                                
                                deleteSuccess = YES;
                                
                            } failure:failBlock];
                            
                        } failure:failBlock];
                    });
            } failure:failBlock];
            
            
        } failure:failBlock];
        
    } progress:nil failure:failBlock];
}

#warning Posting a test image will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post image for testing - This is dangerous
 */
-(void)postTestImage:(void(^)(IMGImage *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:imgurUnitTestParams[@"title"] description:@"Test Description" linkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        if(success)
            success(image, ^{
                
                //remove from gallery and delete image
                
                [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                    
                    deleteSuccess = YES;
                    
                } failure:failBlock];
            });
        
    } progress:nil failure:failBlock];
}

#warning Posting a test gallery album will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post gallery alboum for testing - This is dangerous
 */
-(void)postTestGalleryAlbumWithOneImage:(void(^)(IMGGalleryAlbum *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:imgurUnitTestParams[@"title"] description:@"Test Image Description" linkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        [IMGAlbumRequest createAlbumWithTitle:imgurUnitTestParams[@"title"] description:@"Test Album Description" imageIDs:@[image.imageID] privacy:IMGAlbumPublic layout:IMGHorizontalLayout cover:image success:^(NSString *albumID, NSString * albumDeletehash) {
            
            expect(albumID).notTo.beNil();
            
            [IMGGalleryRequest submitAlbumWithID:albumID title:imgurUnitTestParams[@"title"] terms:YES success:^(){
                
                [IMGGalleryRequest albumWithID:albumID success:^(IMGGalleryAlbum *galAlbum) {
                    
                    if(success)
                        success(galAlbum, ^{
                            
                            //remove from gallery and delete image
                            [IMGGalleryRequest removeAlbumWithID:albumID success:^(NSString *albumID) {
                                
                                [IMGAlbumRequest deleteAlbumWithID:albumID success:^(NSString *albumID) {
                                    
                                    [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                                        
                                        deleteSuccess = YES;
                                        
                                    } failure:failBlock];
                                    
                                } failure:failBlock];
                                
                            } failure:failBlock];
                        });
                    
                } failure:failBlock];
                
            } failure:failBlock];
            
        } failure:failBlock];
        
    } progress:nil failure:failBlock];
}

#warning Posting a test album will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post album for testing - This is dangerous
 */
-(void)postTestAlbumWithOneImage:(void(^)(IMGAlbum *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:imgurUnitTestParams[@"title"] description:@"Test Image Description" linkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        [IMGAlbumRequest createAlbumWithTitle:imgurUnitTestParams[@"title"] description:@"Test Album Description" imageIDs:@[image.imageID] privacy:IMGAlbumPublic layout:IMGHorizontalLayout cover:image.imageID success:^(NSString * albumID, NSString * deletehash) {
            
            expect(albumID).notTo.beNil();
            
            [IMGAlbumRequest albumWithID:albumID success:^(IMGAlbum *album) {
                
                if(success)
                    success(album, ^{
                        
                        [IMGAlbumRequest deleteAlbumWithID:album.albumID success:^() {
                            
                            [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                                
                                deleteSuccess = YES;
                                
                            } failure:failBlock];
                            
                        } failure:failBlock];
                    });
                
            } failure:failBlock];
        
        } failure:failBlock];
    } progress:nil failure:failBlock];
}

#pragma mark - IMGSessionDelegate Delegate methods

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url completion:(void (^)())completion{
    //show external webview to allow auth
    
#if TARGET_OS_IPHONE
    //cannot open url in iphone unit test, not an app
    XCTAssert(nil, @"Fail");
#elif TARGET_OS_MAC
    [[NSWorkspace sharedWorkspace] openURL:url];
#endif
    
    //need to manually enter pin for testing
    NSLog(@"Enter the code PIN");
    char pin[20];
    scanf("%s", pin);
    
    //send pin code to retrieve access tokens
    [[IMGSession sharedInstance] setAuthenticationInputCode:[NSString stringWithUTF8String:pin]];
    
    //we need to continue previous requests this way
    completion();
}

-(void)imgurSessionModelFetched:(id)model{
    
    NSLog(@"New imgur model fetched: %@", [model description]);
}

-(void)imgurSessionRateLimitExceeded{
    
    NSLog(@"Hit rate limit");
    failBlock(nil);
}

-(void)imgurSessionNewNotifications:(NSArray *)freshNotifications{
    
    if(freshNotifications.count)
        NSLog(@"new notifications: %@", [freshNotifications description]);
}


-(void)imgurSessionUserRefreshed:(IMGAccount *)user{
    
    NSLog(@"User refreshed: %@", [user description]);
}

-(void)imgurRequestFailed:(NSError *)error{
    
    NSLog(@"Request failed: %@", [error description]);
}

@end
