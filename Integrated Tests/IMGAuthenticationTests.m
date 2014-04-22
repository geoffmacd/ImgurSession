    //
//  IMGAuthenticationTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-25.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


#import "IMGIntegratedTestCase.h"

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

@end



@interface IMGAuthenticationTests : IMGIntegratedTestCase

@end

@implementation IMGAuthenticationTests

#pragma mark - Testing Authentication

-(void)testGarbageAccessToken{
 
     __block BOOL isSuccess;
    
    //after getting correct tokens
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
         //sets bad access token in header which will cause re-auth with correct refresh token
        [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
         
         //should fail and trigger re-auth
         [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
         
             isSuccess = YES;
             expect(account.username).beTruthy();
         
         } failure:failBlock];
    } failure:failBlock];
     
     expect(isSuccess).will.beTruthy();
}
    
-(void)testGarbageRefreshToken{
 
     __block BOOL isSuccess = NO;
    
    //after getting correct tokens
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        //should fail request, then attempt refresh, should fail refresh, then attempt code input before retrieving new refresh code and continuing requests
        
        //set bad refresh token
        [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
        [[IMGSession sharedInstance] setRefreshToken:@"blahblahblah"];
        
        //should fail request, then attempt refresh, should fail refresh, then attempt code input before retrieving new refresh code and continuing requests
        [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
            
            //should go here
            isSuccess = YES;
            
        } failure:failBlock];
        
        
    } failure:failBlock];
    
    
    expect(isSuccess).will.beTruthy();
}

-(void)testImageNotFound{
    
    __block BOOL isSuccess = NO;
    
    //should fail request, then attempt refresh, should fail refresh, then attempt code input before retrieving new refresh code and continuing requests
    
    [IMGImageRequest imageWithID:@"fdsfdsfdsa" success:^(IMGImage *image) {
        
        //should not success
        failBlock([NSError errorWithDomain:IMGErrorDomain code:0 userInfo:nil]);
        
    } failure:^(NSError *error) {
        
        expect(error.code == 404).beTruthy();
        
        //should go here
        isSuccess = YES;
        
    }];
    
    expect(isSuccess).will.beTruthy();
}

#pragma mark - Testing Rate Limit tracking

-(void)testTrackingClientRateLimiting{
    
    __block BOOL isSuccess;
    
    //get original copy of credits remaining
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        NSInteger remaining = [[IMGSession sharedInstance] creditsUserRemaining];
        
        //should fail and trigger re-auth
        [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
            
            //ensure counter has gone down since we've done one request
            expect([[IMGSession sharedInstance] creditsUserRemaining]).beLessThan(remaining);
            isSuccess = YES;
            
        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

@end
