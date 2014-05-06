//
//  IMGNotificationTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


#import "IMGIntegratedTestCase.h"   

@interface IMGNotificationTests : IMGIntegratedTestCase

@end


@implementation IMGNotificationTests

- (void)testLoadNotifications{
    
    __block BOOL isSuccess;
    
    [IMGNotificationRequest unreadNotifications:^(NSArray * notifications) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).willNot.beNil();
}

- (void)testLoadNotificationsAndMarkOneAsViewed{
    
    __block BOOL isSuccess;
    
    [IMGNotificationRequest unreadNotifications:^(NSArray * notifications) {
        
        IMGNotification * first = [notifications firstObject];
        
        if(first){
        
            //mark first one as viewed
            [IMGNotificationRequest notificationViewed:first.notificationID success:^{
                
                isSuccess = YES;
                
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testLoadStaleNotifications{
    
    __block BOOL isSuccess;
    
    [IMGNotificationRequest allNotifications:^(NSArray * notifications) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).willNot.beNil();
}

-(void)testSessionRefreshsNotifications{
    __block BOOL isSuccess;
    
    //force login
    [[IMGSession sharedInstance] refreshUserAccount:^(IMGAccount *user) {
        
        //waits until notification refresh happens after 30 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            isSuccess = YES;
        });
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

@end
