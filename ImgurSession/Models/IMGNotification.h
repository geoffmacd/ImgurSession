//
//  IMGNotification.h
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

@class IMGComment, IMGMessage;

/**
 Model object class to represent user notifications. https://api.imgur.com/models/notifications
 */
@interface IMGNotification : IMGModel

/**
 notification ID
 */
@property (readonly,nonatomic) NSString * notificationId;
/**
 Account ID notification is associated with
 */
@property (readonly,nonatomic) NSInteger accountId;
/**
 Has notification been viewed yet?
 */
@property (readonly,nonatomic) BOOL isViewed;
/**
 The notification content. Currently uses IMGComment or IMGMessage
 */
@property (readonly,nonatomic) BOOL isReply;
@property (readonly,nonatomic) IMGComment * reply;
@property (readonly,nonatomic) IMGMessage * message;



- (instancetype)initReplyNotificationWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

- (instancetype)initMessageNotificationWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

@end
