//
//  IMGNotificationTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


#import "IMGTestCase.h"

#warning: Must have at least one new and old notification

@interface IMGNotificationTests : IMGTestCase

@end


@implementation IMGNotificationTests

- (void)testLoadNotifications{
    
    __block BOOL isSuccess;
    
    [IMGNotificationRequest notifications:^(NSArray * notifications) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).willNot.beNil();
}

- (void)testLoadNotificationsAndMarkOneAsViewed{
    
    __block BOOL isSuccess;
    
    [IMGNotificationRequest notifications:^(NSArray * notifications) {
        
        IMGNotification * first = [notifications firstObject];
        
        if(first){
        
            //mark first one as viewed
            [IMGNotificationRequest notificationViewed:first.notificationId success:^{
                
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
    
    [IMGNotificationRequest notificationsWithFresh:NO success:^(NSArray * notifications) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).willNot.beNil();
}
@end
