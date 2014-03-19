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
+ (void)commentWithId:(NSString *)commentId withReplies:(BOOL)replies success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
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
+ (void)submitComment:(NSString*)caption withImageId:(NSInteger)imageId withParentId:(NSInteger)parentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 @param caption comment string
 @param imageId id of image to comment on
 @param parentCommentId id of parent comment to reply to
 @return signal with request
 */
+ (void)replyToComment:(NSString*)caption withImageId:(NSInteger)imageId withCommentId:(NSInteger)parentCommentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;

#pragma mark - Delete
/**
 @param commentId comment id to delete
 @return signal with request
 */
+ (void)deleteCommentWithId:(NSString *)commentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;

#pragma mark - Vote
/**
 @param commentId comment id to vote on
 @param vote vote to give comment
 @return signal with request
 */
+ (void)voteCommentWithId:(NSString *)commentId withVote:(NSString*)vote success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Report
/**
 @param commentId comment id to report
 @return signal with request
 */
+ (void)reportCommentWithId:(NSString *)commentId success:(void (^)())success failure:(void (^)(NSError *))failure;

@end
