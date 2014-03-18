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
    
        
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    //need various values such as image title
    imgurVariousValues = infos[@"imgurVariousValues"];
    
    // Initializing the client
    NSDictionary *imgurClient = infos[@"imgurClient"];
    NSString *clientID = imgurClient[@"id"];
    NSString *clientSecret = imgurClient[@"secret"];
    
    //Lazy init, may already exist
    IMGSession * ses = [IMGSession sharedInstanceWithClientID:clientID secret:clientSecret];
    [ses setDelegate:self];
    if([imgurClient[@"refreshToken"] length])
        ses.refreshToken = imgurClient[@"refreshToken"];
    //[ses setGarbageAuth];
    
    [self authenticateUsingOAuthWithPINAsync];
    
    //failure block
    failBlock = ^(NSError *error) {
        XCTAssert(nil, @"FAIL");
    };
    
    //Ensure client data is avaialble for authentication to proceed
    XCTAssertTrue(clientID, @"Client ID is missing");
    XCTAssertTrue(clientSecret, @"Client secret is missing");
    
    //30 second timeout
    [Expecta setAsynchronousTestTimeout:30.0];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Test authentication

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
@end
