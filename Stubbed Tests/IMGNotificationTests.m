//
//  IMGNotificationTests.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


#import "IMGTestCase.h"

@interface IMGNotificationTests : IMGTestCase

@end


@implementation IMGNotificationTests

- (void)testLoadNotifications{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"freshnotification.json"];
    
    [IMGNotificationRequest unreadNotifications:^(NSArray * notifications) {
        
        expect(notifications).haveCountOf(1);
        IMGNotification * first = [notifications firstObject];
        expect(first).beInstanceOf([IMGNotification class]);
        expect(first.notificationID).beTruthy();
        expect(first.accountID).beTruthy();
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testViewedNotification{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"deletenotification.json"];

    //mark first one as viewed
    [IMGNotificationRequest notificationViewed:@"dsgdsg" success:^{
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testLoadStaleNotifications{
    
    __block BOOL isSuccess;
    [self stubWithFile:@"allnotifications.json"];
    
    [IMGNotificationRequest allNotifications:^(NSArray * notifications) {
        
        expect(notifications).haveCountOf(1);
        IMGNotification * first = [notifications firstObject];
        expect(first).beInstanceOf([IMGNotification class]);
        expect(first.notificationID).beTruthy();
        expect(first.accountID).beTruthy();
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}
@end
