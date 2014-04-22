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
     
     //sets bad access token in header which will cause re-auth with correct refresh token
    [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
     
     //should fail and trigger re-auth
     [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
     
         isSuccess = YES;
         expect(account.username).beTruthy();
     
     } failure:failBlock];
     
     expect(isSuccess).will.beTruthy();
}
    
-(void)testGarbageRefreshAndAccessToken{
 
     __block BOOL isSuccess = NO;
     
     //set bad refresh token and access token
    [[IMGSession sharedInstance] setRefreshToken:@"blahblahblah"];
    [[IMGSession sharedInstance].requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@", @"BadAccessToken"] forHTTPHeaderField:@"Authorization"];
    
     //should fail request, then attempt refresh, should fail refresh, then attempt code input before retrieving new refresh code and continuing requests
     [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
         
         //should go here
         isSuccess = YES;
     
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
