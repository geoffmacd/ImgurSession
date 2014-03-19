//
//  IMGCommentRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

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
+ (void)commentWithID:(NSString *)commentId withReplies:(BOOL)replies success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 @param comment IMGComment object to fetch replies for
 @return signal with request
 */
+ (void)repliesWithComment:(IMGComment*)comment success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;

#pragma mark - Create
/**
 @param caption comment string
 @param imageId id of image to comment on
 @param parentId id of parent image to comment on
 @return signal with request
 */
+ (void)submitComment:(NSString*)caption withImageID:(NSInteger)imageID withParentID:(NSInteger)parentID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 @param caption comment string
 @param imageId id of image to comment on
 @param parentCommentId id of parent comment to reply to
 @return signal with request
 */
+ (void)replyToComment:(NSString*)caption withImageID:(NSInteger)imageID withCommentID:(NSInteger)parentCommentID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;

#pragma mark - Delete
/**
 @param commentId comment id to delete
 */
+ (void)deleteCommentWithID:(NSString *)commentID success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Vote
/**
 @param commentId comment id to vote on
 @param vote vote to give comment
 @return signal with request
 */
+ (void)voteCommentWithID:(NSString *)commentID withVote:(NSString*)vote success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Report
/**
 @param commentId comment id to report
 @return signal with request
 */
+ (void)reportCommentWithID:(NSString *)commentID success:(void (^)())success failure:(void (^)(NSError *))failure;

@end
