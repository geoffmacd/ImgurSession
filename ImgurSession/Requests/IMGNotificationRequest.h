//
//  IMGNotificationRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"


@class IMGNotification;

/**
 User notification requests. https://api.imgur.com/endpoints/notification
 */
@interface IMGNotificationRequest : IMGEndpoint

#pragma mark - Load
/**
 Get all fresh notifications for the user that's currently logged in. Must be logged in.
 */
+ (void)notifications:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Get all notifications for the user that's currently logged in. Must be logged in.
 */
+ (void)notificationsWithFresh:(BOOL)freshOnly success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Returns the data about a specific notification. Must be logged in.
 */
+ (void)notificationWithID:(NSString*)notificationId success:(void (^)(IMGNotification *))success failure:(void (^)(NSError *))failure;


#pragma mark - Delete
/**
 Marks a notification as viewed, this way it no longer shows up in the basic notification request. Must be logged in.
 */
+ (void)notificationViewed:(NSString *)notificationId success:(void (^)())success failure:(void (^)(NSError *))failure;


@end
