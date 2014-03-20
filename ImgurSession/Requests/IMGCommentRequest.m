//
//  IMGCommentRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGCommentRequest.h"
#import "IMGComment.h"
#import "IMGSession.h"

@implementation IMGCommentRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"comment";
}

#pragma mark - Load

+ (void)commentWithID:(NSUInteger)commentID withReplies:(BOOL)replies success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:[NSString stringWithFormat:@"%lu", (unsigned long)commentID]];
    
    if(replies)
        path = [self pathWithId:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"replies"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGComment *comment = [[IMGComment alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(comment);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

+ (void)repliesWithComment:(IMGComment*)comment success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
#warning incorrect
    
    return [self commentWithID:comment.commentId withReplies:YES success:success failure:failure];
}

#pragma mark - Create

+ (void)submitComment:(NSString*)caption withImageID:(NSString *)imageId withParentID:(NSUInteger)parentId success:(void (^)(NSUInteger))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:imageId];
    
    NSDictionary * params;
    
    if(parentId)
        params = @{@"image_id":imageId,@"comment":caption,@"parent_id":[NSNumber numberWithInteger:parentId]};
    else
        params = @{@"image_id":imageId,@"comment":caption};
        
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //returns string in dictionary for some reason
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * commentId = [f numberFromString:responseObject[@"id"]];
        
        if(success)
            success([commentId integerValue]);
        
    } failure:failure];
}

+ (void)replyToComment:(NSString*)caption withImageID:(NSString*)imageId withCommentID:(NSUInteger)parentCommentId success:(void (^)(NSUInteger))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:[NSString stringWithFormat:@"%ld",(long)parentCommentId]];
    
    NSDictionary * params = @{@"image_id":imageId,@"comment":caption};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //returns string in dictionary for some reason
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * commentId = [f numberFromString:responseObject[@"id"]];
        
        if(success)
            success([commentId integerValue]);
        
    } failure:failure];
}

#pragma mark - Delete

+ (void)deleteCommentWithID:(NSUInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:[NSString stringWithFormat:@"%lu", (unsigned long)commentID]];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

#pragma mark - Vote

+ (void)voteCommentWithID:(NSUInteger)commentID withVote:(NSString*)vote success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"vote" withId2:vote];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Report

+ (void)reportCommentWithID:(NSUInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"vote/report"];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
    
}

@end
