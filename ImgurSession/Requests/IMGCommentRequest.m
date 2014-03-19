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

+ (void)commentWithID:(NSString *)commentID withReplies:(BOOL)replies success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:commentID];
    
    if(replies)
        path = [self pathWithId:commentID withOption:@"replies"];
    
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
    
    return [self commentWithID:comment.commentId withReplies:YES success:success failure:failure];
}

#pragma mark - Create

+ (void)submitComment:(NSString*)caption withImageID:(NSInteger)imageId withParentID:(NSInteger)parentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self path];
    
    NSDictionary * params = @{@"image_id":[NSNumber numberWithInteger:imageId],@"comment":caption,@"parent_id":[NSNumber numberWithInteger:parentId]};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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

+ (void)replyToComment:(NSString*)caption withImageID:(NSInteger)imageId withCommentID:(NSInteger)parentCommentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:[NSString stringWithFormat:@"%ld",(long)imageId]];
    
    NSDictionary * params = @{@"image_id":[NSNumber numberWithInteger:imageId],@"comment":caption};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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

#pragma mark - Delete

+ (void)deleteCommentWithID:(NSString *)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:commentID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

#pragma mark - Vote

+ (void)voteCommentWithID:(NSString *)commentID withVote:(NSString*)vote success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:commentID withOption:@"vote" withId2:vote];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Report

+ (void)reportCommentWithID:(NSString *)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:commentID withOption:@"vote/report"];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
    
}

@end
