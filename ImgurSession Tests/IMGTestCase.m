//
//  IMGTestCase.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-18.
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
- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret;

@end

@implementation IMGTestCase

- (void)setUp {
    [super setUp];
    //run before each test
    
    //5 second timeout
    [Expecta setAsynchronousTestTimeout:5.0];
        
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    
    //need various values such as image title
    imgurUnitTestParams = infos[@"imgurUnitTestParams"];
    testfileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
    
    //failure block
    failBlock = ^(NSError * error) {
        XCTAssert(nil, @"FAIL");
    };
}

- (void)tearDown {
    [super tearDown];
}

-(void)stubWithFile:(NSString * )filename {
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(filename,nil)
                                                statusCode:200 headers:@{@"Content-Type":@"text/json"}];
    }];
}


#pragma mark - Testing Authentication
/*
-(void)testGarbageAccessToken{
    
    __block BOOL isLoaded;
    if(!anon){
        //just sets bad access token in header which will cause re-auth with correct refresh token
        [[IMGSession sharedInstance] setGarbageAuth];
        
        //should fail and trigger re-auth
        [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
            
            isLoaded = YES;
            expect(account.username).beTruthy();
            
        } failure:failBlock];
        
        expect(isLoaded).will.beTruthy();
    }
}

-(void)testGarbageRefreshToken{
    
    __block BOOL isFailed = NO;
    if(!anon){
        //re-auth will be unsuccessful
        [[IMGSession sharedInstance] setRefreshToken:@"blahblahblah"];
        
        //should fail and trigger re-auth, then fail again
        [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
            
            //should not get here
            expect(0).beTruthy();
            
        } failure:^(NSError *error) {
            
            isFailed = YES;
        }];

        expect(isFailed).will.beTruthy();
    }
}
 */

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
