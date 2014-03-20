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
    
    __block NSArray * notes;
    
    [IMGNotificationRequest notifications:^(NSArray * notifications) {
        
        notes = notifications;

        
    } failure:failBlock];
    
    expect(notes).willNot.beNil();
}

- (void)testLoadNotificationsAndMarkOneAsViewed{
    
    __block BOOL viewed;
    
    [IMGNotificationRequest notifications:^(NSArray * notifications) {
        
        IMGNotification * first = [notifications firstObject];
        
        //mark first one as viewed
        [IMGNotificationRequest notificationViewed:first.notificationId success:^{
            
            viewed = YES;
            
        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(viewed).will.beTruthy();
}

- (void)testLoadStaleNotifications{
    
    __block NSArray * notes;
    
    [IMGNotificationRequest notificationsWithFresh:NO success:^(NSArray * notifications) {
        
        notes = notifications;
        
    } failure:failBlock];
    
    expect(notes).willNot.beNil();
}
@end
