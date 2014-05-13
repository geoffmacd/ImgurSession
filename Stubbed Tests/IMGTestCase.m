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

@end

@implementation IMGTestCase

- (void)setUp {
    [super setUp];
    //run before each test
    
    //5 second timeout
    [Expecta setAsynchronousTestTimeout:5.0];
        
    // Storing various testing values
    NSDictionary *infos = [[NSBundle bundleForClass:[self class]] infoDictionary];
    
    //dummy auth session that will always claim to be properly authenticated even though its not, otherwise we wrongly attempt refresh
    [IMGSession authenticatedSessionWithClientID:@"ffdsf" secret:@"dfdsf" authType:IMGPinAuth withDelegate:self];
    [[IMGSession sharedInstance] setRefreshToken:@"efssdfsd"];
    [[IMGSession sharedInstance] setAccessToken:@"efssdfsd"];
    [[IMGSession sharedInstance] setAccessTokenExpiry:[NSDate dateWithTimeIntervalSinceNow:10000000]];
    //no reachability for offline tests
    [[IMGSession sharedInstance] setImgurReachability:nil];
    
    //need various values such as image title
    imgurUnitTestParams = infos[@"imgurUnitTestParams"];
    
    
    testfileURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"image-example" ofType:@"jpg"]];
    testGifURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:@"gif"]];
    
    //failure block
    failBlock = ^(NSError * error) {
        
        NSLog(@"Error : %@", [error localizedDescription]);
        
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

-(void)stubWithFile:(NSString * )filename withHeader:(NSDictionary*)headerDict{
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"Content-Type":@"text/json"}];
        [dict addEntriesFromDictionary:headerDict];
        
        // Stub it with our "wsresponse.json" stub file
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(filename,nil)
                                                statusCode:200 headers:[NSDictionary dictionaryWithDictionary:dict]];
    }];
}

-(void)stubWithFile:(NSString *)filename withStatusCode:(int)status {
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(filename,nil)
                                                statusCode:status headers:@{@"Content-Type":@"text/json"}];
    }];
}
#pragma mark - IMGSessionDelegate Delegate methods

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url completion:(void (^)())completion{
    
    self.calledImgurView = YES;
}

-(void)imgurSessionModelFetched:(id)model{
    
    NSLog(@"New imgur model fetched: %@", [model description]);
}

-(void)imgurSessionRateLimitExceeded{
    
    NSLog(@"Hit rate limit");
    failBlock(nil);
}

@end
