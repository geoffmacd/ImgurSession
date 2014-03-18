//
//  ImgurSession_Tests.m
//  ImgurSession Tests
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCAsyncTestCase/XCTestCase+AsyncTesting.h>

#import "IMGSession.h"

#define kTestTimeOut     30     //seconds

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

@end

@interface IMGSession_Tests : XCTestCase <IMGSessionDelegate>{
    //various metadata to store
    NSDictionary *imgurVariousValues;
    NSString *refreshToken;
    
    __block void(^ failBlock)(NSError * error);
}

@end

@implementation IMGSession_Tests

//run before each test
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Storing various testing values
    
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    //need various values such as image title
    imgurVariousValues = infos[@"imgurVariousValues"];
    
    // Initializing the client
    NSDictionary *imgurClient = infos[@"imgurClient"];
    NSString *clientID = imgurClient[@"id"];
    NSString *clientSecret = imgurClient[@"secret"];
    //cannot open url in iphone unit test, not an app
    refreshToken = imgurClient[@"refreshToken"];
    
    //Lazy init, may already exist
    IMGSession * ses = [IMGSession sharedInstanceWithClientID:clientID secret:clientSecret];
    [ses setDelegate:self];
//    [ses setGarbageAuth];
    
    //failure block
    __weak id testClass = self;
    failBlock = ^(NSError *error) {
        [testClass notify:XCTAsyncTestCaseStatusFailed];
    };
    
    
    //Ensure client data is avaialble for authentication to proceed
    XCTAssertTrue(clientID, @"Client ID is missing");
    XCTAssertTrue(clientSecret, @"Client secret is missing");
}

//run after each test
- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Test authentication

/*
 Tests authentication and sets global access token to save for rest of the test. Needs to be marked test1 so that it is run first (alphabetical order)
 **/
-(void)test1AuthenticateUsingOAuthWithPINAsync
{
    IMGSession *client = [IMGSession sharedInstance];
    
    //sets refresh token if available, required for iPhone unit test
    if([refreshToken length]){
        [client setRefreshToken:refreshToken];
        [client setLastAuthType:IMGPinAuth];
        
        //should retrieve new access code
        [client refreshAuthentication:^(NSString * refresh) {
            
            NSLog(@"Refresh token: %@", refresh);
            [self notify:XCTAsyncTestCaseStatusSucceeded];
            
        } failure:^(NSError *error) {
            
            NSLog(@"%@", error.localizedRecoverySuggestion);
            [self notify:XCTAsyncTestCaseStatusFailed];
            
        }];
    } else {
        
        //goes to safari from delegate call
        [client refreshAuthentication:nil failure:nil];
        
        //need to manually enter pin for testing
        NSLog(@"Enter the code PIN");
        char pin[20];
        scanf("%s", pin);
        
        //send pin code to retrieve access tokens
        [client authenticateWithType:IMGPinAuth withCode:[NSString stringWithUTF8String:pin] success:^(NSString *refresh) {
            
            NSLog(@"Refresh token: %@", refresh);
            [self notify:XCTAsyncTestCaseStatusSucceeded];
            
        } failure:^(NSError *error) {
            
            NSLog(@"%@", error.localizedRecoverySuggestion);
            [self notify:XCTAsyncTestCaseStatusFailed];
        }];
    }
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

#pragma mark - Test Account endpoints


- (void)testAccountLoading{
    
    [IMGAccountRequest accountWithUsername:@"me" success:^(IMGAccount *account) {
        
        [IMGAccountRequest accountGalleryFavourites:@"me" success:^(NSArray * gallery) {
            
            [IMGAccountRequest accountFavourites:@"me" success:^(NSArray * favourites) {
                
                [IMGAccountRequest accountSubmissionsPage:0 withUsername:@"me" success:^(NSArray * submissions) {
                    
                    [IMGAccountRequest accountGalleryProfile:@"me" success:^(IMGGalleryProfile * profile) {
                        
                        
                        [self notify:XCTAsyncTestCaseStatusSucceeded];
                        
                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

- (void)testAccountSettings{
    
    [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
        
        [IMGAccountRequest changeAccountWithBio:@"test bio" messagingEnabled:YES publicImages:YES albumPrivacy:IMGAlbumPublic acceptedGalleryTerms:YES success:^{
            
            [IMGAccountRequest changeAccountWithBio:@"test bio 2" success:^{
                
                [self notify:XCTAsyncTestCaseStatusSucceeded];
            
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

- (void)testAccountItems{

    [IMGAccountRequest accountGalleryFavourites:@"me" success:^(NSArray * gallery) {
        
        [IMGAccountRequest accountFavourites:@"me" success:^(NSArray * favourites) {
            
            [IMGAccountRequest accountSubmissionsPage:0 withUsername:@"me" success:^(NSArray * submissions) {
                
                [IMGAccountRequest accountReplies:^(NSArray * replies) {
                    
                    [IMGAccountRequest accountRepliesWithFresh:NO success:^(NSArray * replies) {
                        
                        [self notify:XCTAsyncTestCaseStatusSucceeded];
                        
                    } failure:failBlock];
                    
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

- (void)testAccountComments{
    
    [IMGAccountRequest accountCommentIds:@"me" success:^(NSArray * comments) {
        
        [IMGAccountRequest accountCommentWithId:[comments firstObject] success:^(IMGComment * comment) {
            
            [IMGAccountRequest accountCommentsWithUsername:@"me" success:^(NSArray * comments) {
                
                [IMGAccountRequest accountCommentCount:@"me" success:^(NSNumber * numcomments) {
                    
                    
                    [self notify:XCTAsyncTestCaseStatusSucceeded];
                    
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

- (void)testAccountImages{
    
    [IMGAccountRequest accountImageIds:@"me" success:^(NSArray * images) {
        
        [IMGAccountRequest accountImageWithId:[images firstObject] success:^(IMGImage * image) {
            
            [IMGAccountRequest accountImagesWithUsername:@"me" withPage:0 success:^(NSArray * images) {
                
                [IMGAccountRequest accountImageCount:@"me" success:^(NSNumber * numImages) {
                    
                    [self notify:XCTAsyncTestCaseStatusSucceeded];
                    
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

- (void)testAccountAlbums{
    
    [IMGAccountRequest accountAlbumIds:@"me" success:^(NSArray * albums) {
        
        [IMGAccountRequest accountAlbumWithId:[albums firstObject] success:^(IMGAlbum * album) {
            
            [IMGAccountRequest accountAlbumsWithUsername:@"me" withPage:0 success:^(NSArray * albums) {
                
                //always returns 502??
                [IMGAccountRequest accountAlbumCount:@"me" success:^(NSNumber * numAlbums) {
                    
                    [self notify:XCTAsyncTestCaseStatusSucceeded];
                    
                } failure:failBlock];
            } failure:failBlock];
        } failure:failBlock];
    } failure:failBlock];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
}

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url{
    
#if TARGET_OS_IPHONE
    //cannot open url in iphone unit test, not an app
    [self notify:XCTAsyncTestCaseStatusFailed];
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

#pragma mark - Test Album endpoints

/*
 Tests creating, submitting publicly, getting, removing from public and deleting album
 **/
- (void)testAlbumWorkflowAsync{

}

#pragma mark - Test Image endpoints

/*
 Tests uploading image, submission process, removal and deletion of individual images
 **/
- (void)testImageWorkflowAsync{
    
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
}

#pragma mark - Test Gallery endpoints

/*
 Tests
 **/
- (void)testGallery{
    
    [IMGGalleryRequest galleryWithParameters:nil success:^(NSArray * images) {
        
        [self notify:XCTAsyncTestCaseStatusSucceeded];
        
    } failure:^(NSError * err) {
        
        
    }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kTestTimeOut];
    
}

@end
