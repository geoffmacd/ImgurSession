//
//  IMGTestCase.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-18.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

//add read-write prop
@interface IMGSession ()

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;
@property (readwrite,nonatomic) NSInteger creditsUserRemaining;
@property (readwrite,nonatomic) NSInteger creditsUserLimit;
@property (readwrite,nonatomic) NSInteger creditsUserReset;
@property (readwrite,nonatomic) NSInteger creditsClientRemaining;
@property (readwrite,nonatomic) NSInteger creditsClientLimit;
@property  (readwrite,nonatomic) NSInteger warnRateLimit;

/**
 Testing function to remove auth
 */
-(void)setGarbageAuth;
@end

@implementation IMGTestCase

- (void)setUp {
    [super setUp];
    //run before each test
    
    //30 second timeout
    [Expecta setAsynchronousTestTimeout:30.0];
    
        
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    //need various values such as image title
    imgurVariousValues = infos[@"imgurVariousValues"];
    
    // Initializing the client
    NSDictionary *imgurClient = infos[@"imgurClient"];
    NSString *clientID = imgurClient[@"id"];
    NSString *clientSecret = imgurClient[@"secret"];
    
    testfileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
    
    //Lazy init, may already exist
    IMGSession * ses = [IMGSession sharedInstanceWithClientID:clientID secret:clientSecret];
    [ses setDelegate:self];
    if([imgurClient[@"refreshToken"] length])
        ses.refreshToken = imgurClient[@"refreshToken"];
//    [ses setAccessToken:@"f9e5417af574ee441a2cc4b30652a887fe9fccca"];
//    [ses setAccessTokenExpiry: [NSDate dateWithTimeIntervalSinceNow:NSIntegerMax]];
    //[ses setGarbageAuth];
    
    [self authenticateUsingOAuthWithPINAsync];
    
    //failure block
//    failBlock = ^(NSError *error) {
//        XCTAssert(nil, @"FAIL");
//    };
    
    //Ensure client data is avaialble for authentication to proceed
    XCTAssertTrue(clientID, @"Client ID is missing");
    XCTAssertTrue(clientSecret, @"Client secret is missing");
    
    
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
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:@"Test Image" description:@"Test Description" andLinkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        [IMGGalleryRequest submitImageWithID:image.imageID title:@"Test Gallery" terms:YES success:^(IMGGalleryImage * galImage) {
            
            expect(galImage).notTo.beNil();
            
            if(success)
                success(galImage, ^{
                    
                    //remove from gallery and delete image
                    [IMGGalleryRequest removeImageWithID:galImage.imageID success:^(NSString *albumID) {
                        
                        [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                            
                            deleteSuccess = YES;
                            
                        } failure:failBlock];
                        
                    } failure:failBlock];
                });
            
        } failure:failBlock];
        
    } failure:failBlock];
}

#warning Posting a test image will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post image for testing - This is dangerous
 */
-(void)postTestImage:(void(^)(IMGImage *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:@"Test Image" description:@"Test Description" andLinkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        if(success)
            success(image, ^{
                
                //remove from gallery and delete image
                
                [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                    
                    deleteSuccess = YES;
                    
                } failure:failBlock];
            });
        
    } failure:failBlock];
}

#warning Posting a test gallery album will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post gallery alboum for testing - This is dangerous
 */
-(void)postTestGalleryAlbumWithOneImage:(void(^)(IMGGalleryAlbum *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:@"Test Image" description:@"Test Image Description" andLinkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        [IMGAlbumRequest createAlbumWithTitle:@"Test Album" description:@"Test Album Description" imageIDs:@[image] privacy:IMGAlbumPublic layout:IMGHorizontalLayout cover:image success:^(IMGAlbum *album) {
            
            expect(album).notTo.beNil();
            
            [IMGGalleryRequest submitAlbumWithID:album.albumID title:@"Test Gallery Album" terms:YES success:^(IMGGalleryAlbum * galAlbum){
                
                expect(galAlbum).notTo.beNil();
                
                if(success)
                    success(galAlbum, ^{
                        
                        //remove from gallery and delete image
                        [IMGGalleryRequest removeAlbumWithID:album.albumID success:^(NSString *albumID) {
                            
                            [IMGAlbumRequest deleteAlbumWithID:album.albumID success:^(NSString *albumID) {
                                
                                [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                                    
                                    deleteSuccess = YES;
                                    
                                } failure:failBlock];
                                
                            } failure:failBlock];
                            
                        } failure:failBlock];
                    });
                
            } failure:failBlock];
            
        } failure:failBlock];
        
    } failure:failBlock];
}

#warning Posting a test album will create spam if not deleted successfully by this method
/**
 Wraps around test case block to provide one way to post album for testing - This is dangerous
 */
-(void)postTestAlbumWithOneImage:(void(^)(IMGAlbum *,void(^)()))success{
    
    __block BOOL deleteSuccess = NO;
    
    [IMGImageRequest uploadImageWithFileURL:testfileURL title:@"Test Image" description:@"Test Image Description" andLinkToAlbumWithID:nil success:^(IMGImage *image) {
        
        expect(image).notTo.beNil();
        
        [IMGAlbumRequest createAlbumWithTitle:@"Test Album" description:@"Test Album Description" imageIDs:@[image] privacy:IMGAlbumPublic layout:IMGHorizontalLayout cover:image success:^(IMGAlbum *album) {
            
            expect(album).notTo.beNil();
            
            if(success)
                success(album, ^{
                    
                    [IMGAlbumRequest deleteAlbumWithID:album.albumID success:^(NSString *albumID) {
                        
                        [IMGImageRequest deleteImageWithID:image.imageID success:^() {
                            
                            deleteSuccess = YES;
                            
                        } failure:failBlock];
                        
                    } failure:failBlock];
                });
            
        } failure:failBlock];
        
    } failure:failBlock];
}


#pragma mark - Test authentication run on setup

/*
 Tests authentication and sets global access token to save for rest of the test. Needs to be marked test1 so that it is run first (alphabetical order)
 **/
-(void)authenticateUsingOAuthWithPINAsync
{
    IMGSession *session = [IMGSession sharedInstance];
    
    //sets refresh token if available, required for iPhone unit test
    if([session sessionAuthState] == IMGAuthStateExpired){
        
        //should retrieve new access code
        [session refreshAuthentication:^(NSString * refresh) {
            
            NSLog(@"Refresh token: %@", refresh);
            
        } failure:^(NSError *error) {
            
            NSLog(@"%@", error.localizedRecoverySuggestion);
            
        }];
    } else if ([session sessionAuthState] == IMGAuthStateNone) {
        
        //set to pin
        [session setLastAuthType:IMGPinAuth];
        //go straight to delegate call
        [self imgurSessionNeedsExternalWebview:[[IMGSession sharedInstance] authenticateWithExternalURLForType:IMGPinAuth]];
        
        //need to manually enter pin for testing
        NSLog(@"Enter the code PIN");
        char pin[20];
        scanf("%s", pin);
        
        //send pin code to retrieve access tokens
        [session authenticateWithType:IMGPinAuth withCode:[NSString stringWithUTF8String:pin] success:^(NSString *refresh) {
            
            NSLog(@"Refresh token: %@", refresh);
        } failure:^(NSError *error) {
            
            NSLog(@"%@", error.localizedRecoverySuggestion);
        }];
    }
    
    //both cases should lead to access token
    expect(session.accessToken).willNot.beNil();
//    expect(session.refreshToken).willNot.beNil();
}

#pragma mark - IMGSessionDelegate Delegate methods

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url{
    //show external webview to allow auth
    
#if TARGET_OS_IPHONE
    //cannot open url in iphone unit test, not an app
    XCTAssert(nil, @"Fail");
#elif TARGET_OS_MAC
    [[NSWorkspace sharedWorkspace] openURL:url];
#endif
}

-(void)imgurSessionModelFetched:(id)model{
    
    NSLog(@"New imgur model fetched: %@", [model description]);
}

-(void)imgurSessionRateLimitExceeded{
    
    NSLog(@"Hit rate limit");
    failBlock(nil);
}
@end
