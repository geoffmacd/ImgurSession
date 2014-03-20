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
@property (readonly,nonatomic) NSDate * datetime;
/**
 Parent convoId
 */
@property (readonly,nonatomic) NSInteger conversationID;



//ALL MESSAGE ENDPOINTS ARE DEPRECATED, USE CONVERSATION INSTEAD

@end
