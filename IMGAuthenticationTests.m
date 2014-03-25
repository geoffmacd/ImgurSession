//
//  IMGAuthenticationTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-25.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


#import "IMGIntegratedTestCase.h"

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

@interface IMGAuthenticationTests : IMGIntegratedTestCase

@end

@implementation IMGAuthenticationTests

#pragma mark - Testing Authentication

-(void)testGarbageAccessToken{
 
     __block BOOL isSuccess;
     
     //just sets bad access token in header which will cause re-auth with correct refresh token
     [[IMGSession sharedInstance] setGarbageAuth];
     
     //should fail and trigger re-auth
     [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
     
         isSuccess = YES;
         expect(account.username).beTruthy();
     
     } failure:failBlock];
     
     expect(isSuccess).will.beTruthy();
 }
 
-(void)testGarbageRefreshToken{
 
     __block BOOL isFailed = NO;
     
     //re-auth will be unsuccessful
    [[IMGSession sharedInstance] setRefreshToken:@"blahblahblah"];
    [[IMGSession sharedInstance] setGarbageAuth];
    
     //should fail and trigger re-auth, then fail again
     [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
     
         //should not get here
         expect(0).beTruthy();
     
     } failure:^(NSError *error) {
     
         isFailed = YES;
     }];
     
     expect(isFailed).will.beTruthy();
}

#pragma mark - Testing Rate Limit tracking

-(void)testTrackingClientRateLimiting{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        NSInteger remaining = [[IMGSession sharedInstance] creditsClientRemaining];
        
        //should fail and trigger re-auth
        [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
            
            //ensure counter has gone down since we've done one request
            expect([[IMGSession sharedInstance] creditsClientRemaining]).beLessThan(remaining);
            isSuccess = YES;
            
        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

@end
