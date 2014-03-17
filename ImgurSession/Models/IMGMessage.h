//
//  IMGMessage.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"


/**
 Model object class to represent messages. https://api.imgur.com/models/message
 */
@interface IMGMessage : IMGModel

/**
 Message ID
 */
@property (readonly,nonatomic) NSString * messageId;
/**
 Username who sent the message
 */
@property (readonly,nonatomic) NSString * fromUsername;
/**
 Authors account id
 */
@property (readonly,nonatomic) NSInteger authorId;
/**
 Recipients account id
 */
@property (readonly,nonatomic) NSInteger recipientId;
/**
 message subject
 */
@property (readonly,nonatomic) NSString * subject;
/**
 message body
 */
@property (readonly,nonatomic) NSString * body;
/**
 Readable string of time since now message was sent
 */
@property (readonly,nonatomic) NSString * timeMessage;
/**
 First message Id in thread
 */
@property (readonly,nonatomic) NSInteger parentId;



//ALL MESSAGE ENDPOINTS ARE DEPRECATED, USE CONVERSATION INSTEAD

@end
