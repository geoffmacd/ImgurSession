//
//  IMGCommentRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"
#import "IMGVote.h"

@class IMGComment;

/**
 Comment Requests. https://api.imgur.com/endpoints/comment
 */
@interface IMGCommentRequest : IMGEndpoint

#pragma mark - Load
/**
 @param commentId string Id for comment
 @param replies fetch the replies as well
 @return signal with request
 */
+ (void)commentWithID:(NSInteger)commentId withReplies:(BOOL)replies success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 Fetch replies to a comment
 @param comment IMGComment object to fetch replies for
 @return signal with request
 */
+ (void)repliesWithCommentID:(NSInteger)comment success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark - Create
/**
 Create comment at the parent. Must be logged in.
 @param caption comment string
 @param imageId id of image to comment on
 @param parentId id of parent image to comment on
 */
+ (void)submitComment:(NSString*)caption withImageID:(NSString *)imageID withParentID:(NSInteger)parentID success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure;
/**
 Reply to a parent comment. Must be logged in.
 @param caption comment string
 @param imageId id of image to comment on
 @param parentCommentId id of parent comment to reply to
 */
+ (void)replyToComment:(NSString*)caption withImageID:(NSString *)imageID withCommentID:(NSInteger)parentCommentID success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure;

#pragma mark - Delete
/**
 Delete comment. Must be logged in.
 @param commentId comment id to delete
 */
+ (void)deleteCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Vote
/**
 Vote on a comment. Must be logged in.
 @param commentId comment id to vote on
 @param vote vote to give comment
 */
+ (void)voteCommentWithID:(NSInteger)commentID withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Report
/**
 Report a comment. Must be logged in.
 @param commentId comment id to report
 */
+ (void)reportCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure;

@end
