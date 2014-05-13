//
//  IMGAuthenticationTests.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-28.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

//add read-write prop
@interface IMGSession (TestSession)

@property (readwrite, nonatomic, copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType lastAuthType;
@property (readwrite, nonatomic) NSInteger creditsUserRemaining;
@property (readwrite, nonatomic) NSInteger creditsUserLimit;
@property (readwrite, nonatomic) NSInteger creditsUserReset;
@property (readwrite, nonatomic) NSInteger creditsClientRemaining;
@property (readwrite, nonatomic) NSInteger creditsClientLimit;
@property (readwrite, nonatomic) NSInteger warnRateLimit;

- (void)setAuthorizationHeader:(NSDictionary *)tokens;
-(void)refreshAuthentication:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure;
-(void)authenticate:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure;
-(void)postForAccessTokens:(void (^)())success failure:(void (^)(NSError *error))failure;

@end

@interface IMGAuthenticationTests : IMGTestCase

@end

#pragma mark - Test Authentication is working properly

@implementation IMGAuthenticationTests


//very hard to do since there are multiple requests needed for authentication process

-(void)testMissingParameters{
    __block BOOL isSuccess;
    
    //sets bad access token in header which will cause re-auth with correct refresh token
    [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
    
    [[IMGSession sharedInstance] setClientID:nil];
    [[IMGSession sharedInstance] setSecret:nil];
    [[IMGSession sharedInstance] setRefreshToken:nil];
    [[IMGSession sharedInstance] setAccessToken:nil];
    
    //should just fail with missing params
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        expect(0).beTruthy();
        isSuccess = YES;
        
    } failure:^(NSError *error) {
        
        expect(error.code == IMGErrorMissingClientAuthentication).beTruthy();
        
        isSuccess = YES;
    }];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testBadCode{
    __block BOOL isSuccess;
    
    [[IMGSession sharedInstance] setAuthenticationInputCode:@"badcode"];
    //set access token to nil to ensure we have manually expired access tokens if they exist so that we get IMGAuthStateExpired to refresh
    [IMGSession sharedInstance].accessToken = nil;
    [IMGSession sharedInstance].refreshToken = nil;
    
    [self stubWithFile:@"invalidcode.json" withStatusCode:400];
    
    [[IMGSession sharedInstance] authenticate:^(NSString *refreshToken) {
        
        
    } failure:^(NSError *error) {
        
        expect(error.code == IMGErrorCouldNotAuthenticate).beTruthy();
        isSuccess = YES;
        
    }];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testGarbageAccessToken{
    //regular authenticated request should fail
    
    __block BOOL isSuccess;
    
    [self stubWithFile:@"invalidaccess.json" withStatusCode:403];
    
    [[IMGSession sharedInstance] GET:@"3/account/me" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        failBlock(nil);
        
    } failure:^(NSError *error) {
        
        //expect request to fail due to bad access token, 403
        expect(error.code == IMGErrorForbidden).beTruthy();
        
        isSuccess = YES;
    }];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testGarbageRefreshToken{
    
    __block BOOL isSuccess = NO;
    
        
    //should fail request, then attempt refresh, should fail refresh, then attempt code input before retrieving new refresh code and continuing requests
    
    //set bad refresh token
    [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
    [[IMGSession sharedInstance] setRefreshToken:@"blahblahblah"];
    
    //set expired
    [[IMGSession sharedInstance] setAccessToken:@"dfdsf"];
    //an hour before
    [[IMGSession sharedInstance] setAccessTokenExpiry:[[NSDate date] dateByAddingTimeInterval:-3605]];
    
    
    [self stubWithFile:@"invalidrefresh.json" withStatusCode:400];
    
    //should fail request, with 400
    [[IMGSession sharedInstance] postForAccessTokens:^{
        
        failBlock(nil);
        
    } failure:^(NSError *error) {
        
        expect(error.code == 400).beTruthy();
        expect([error.localizedDescription isEqualToString:@"Invalid refresh token"]).beTruthy();
        
        isSuccess = YES;
    }];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testAccessTokenDateExpiry{
    //test to ensure that upon access token expiry date, we refresh automatically

    __block NSString * oldAccess;
    
    oldAccess = [IMGSession sharedInstance].accessToken;
    
    //hijack refresh to expire in 2 seconds rather than 3600
    NSDictionary * tokens = @{@"refresh_token":[IMGSession sharedInstance].refreshToken,@"access_token":[IMGSession sharedInstance].accessToken,@"expires_in":@2};
    [[IMGSession sharedInstance] setAuthorizationHeader:tokens];
    
    [self stubWithFile:@"refreshedtokens.json"];
    
    //waits until it observes that the accessToken has been updated from the 5 second timeout automatically refreshing auth with refresh
    expect([IMGSession sharedInstance].accessToken != oldAccess).will.beTruthy();
}

-(void)testTrackingClientRateLimiting{
    
    //decrement remaining requests and ensure session picks up the right number
    
    __block BOOL isSuccess;
    
    [self stubWithFile:@"myaccount.json" withHeader:@{@"X-RateLimit-ClientRemaining": @"10000"}];
    
    //get original copy of credits remaining
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        expect([[IMGSession sharedInstance] creditsClientRemaining] == 10000);
        
        //imgur doesn't synchronize the counts instantly for some reason so we wait a second until they do
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            [self stubWithFile:@"myaccount.json" withHeader:@{@"X-RateLimit-ClientRemaining": @"9999"}];
            
            //should fail and trigger re-auth
            [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
                
                //ensure counter has gone down since we've done one request
                expect([[IMGSession sharedInstance] creditsClientRemaining] == 9999);
                isSuccess = YES;
                
            } failure:failBlock];
        });
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}
@end
