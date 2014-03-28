//
//  IMGConversationRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

@class IMGMessage,IMGConversation;

/**
 Conversation requests. https://api.imgur.com/endpoints/conversation
 */
@interface IMGConversationRequest : IMGEndpoint


#pragma mark - Load
/**
 Get list of all conversations for the logged in user.
 */
+ (void)conversations:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Get information about a specific conversation. Includes messages.
 */
+ (void)conversationWithMessageID:(NSInteger)messageID success:(void (^)(IMGConversation *))success failure:(void (^)(NSError *))failure;

#pragma mark - Create
/**
 Create a new message.
 */
+ (void)createMessageWithRecipient:(NSString*)recipient withBody:(NSString*)body success:(void (^)())success failure:(void (^)(NSError *))failure;


#pragma mark - Delete
/**
 @param commentId comment id to delete
 @return signal with request
 */
+ (void)deleteConversation:(NSInteger)convoID success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Report
/**
 Report a user for sending messages that are against the Terms of Service.
 */
+ (void)reportSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Block
/**
 Report a user for sending messages that are against the Terms of Service.
 */
+ (void)blockSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *))failure;
@end
