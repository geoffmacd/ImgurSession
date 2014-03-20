//
//  IMGConversation.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

/**
 Model object class to represent conversation. Not listed on API docs
 */
@interface IMGConversation : IMGModel


/**
 Message ID
 */
@property (readonly,nonatomic) NSUInteger conversationID;
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
@property (readonly,nonatomic) NSString * lastMessage;
/**
 message subject
 */
@property (readonly,nonatomic) NSDate * datetime;
/**
 Number of messages sent back and fortg
 */
@property (readonly,nonatomic) NSInteger messageCount;
/**
 Actual messages send with /{id}
 */
@property (readonly,nonatomic) NSArray * messages;


/**
 Special Init for notifications with different keys
 */
- (instancetype)initWithJSONObjectFromNotification:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

@end
