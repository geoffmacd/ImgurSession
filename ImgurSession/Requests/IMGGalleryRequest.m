//
//  IMGGalleryRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGGalleryRequest.h"
#import "IMGGalleryImage.h"
#import "IMGGalleryAlbum.h"
#import "IMGComment.h"
#import "IMGSession.h"

@implementation IMGGalleryRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"gallery";
}

#pragma mark - Load Gallery Pages

+(void)hotGalleryPage:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    //all default params
    [IMGGalleryRequest hotGalleryPage:page withViralSort:YES success:success failure:failure];
}

+(void)hotGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * params = @{@"section":@"hot", @"page":[NSNumber numberWithInteger:page], @"sort":(viralSort ? @"viral" : @"time")};
    
    [IMGGalleryRequest galleryWithParameters:params success:success failure:failure];
}

+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString * windowStr;
    switch (window) {
        case IMGTopGalleryWindowDay:
            windowStr = @"day";
            break;
        case IMGTopGalleryWindowWeek:
            windowStr = @"week";
            break;
        case IMGTopGalleryWindowMonth:
            windowStr = @"month";
            break;
        case IMGTopGalleryWindowYear:
            windowStr = @"year";
            break;
        case IMGTopGalleryWindowAll:
            windowStr = @"all";
            break;
        default:
            windowStr = @"day";
            break;
    }
    NSString * sortStr = (viralSort ? @"viral" : @"time");
    
    //defauts are viral sort
    NSDictionary * params = @{@"section" : @"top", @"page":[NSNumber numberWithInteger:page], @"window": windowStr, @"sort":sortStr};
    
    [IMGGalleryRequest galleryWithParameters:params success:success failure:failure];
}

+(void)userGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort showViral:(BOOL)showViral success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * params = @{@"section":@"user", @"page":[NSNumber numberWithInteger:page], @"sort":(viralSort ? @"viral" : @"time"), @"showViral": [NSNumber numberWithBool:showViral]};
    
    [IMGGalleryRequest galleryWithParameters:params success:success failure:failure];
}

+(void)galleryWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self path];
    
    [[IMGSession sharedInstance] GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * jsonArray = responseObject;
        NSMutableArray * images = [NSMutableArray new];
        
        for(NSDictionary * json in jsonArray){
            
            if([json[@"is_album"] boolValue]){
                NSError *JSONError = nil;
                IMGGalleryAlbum * album = [[IMGGalleryAlbum alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError)
                    [images addObject:album];
            } else {
                
                NSError *JSONError = nil;
                IMGGalleryImage * image = [[IMGGalleryImage alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError)
                    [images addObject:image];
            }
        }
        if(success)
            success(images);

    } failure:failure];
}

#pragma mark - Load Gallery objects

+(void)imageWithID:(NSString *)imageID success:(void (^)(IMGGalleryImage *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"image" withId2:imageID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(image);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGGalleryAlbum *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"album" withId2:albumID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *JSONError = nil;
        IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(album);
        }
        else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

+ (void)commentsWithGalleryID:(NSString *)galleryObjectId withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString * sortStr;
    switch (commentSort) {
        case IMGGalleryCommentSortBest:
            sortStr = @"best";
            break;
        case IMGGalleryCommentSortHot:
            sortStr = @"hot";
            break;
        case IMGGalleryCommentSortNew:
            sortStr = @"new";
            break;
        default:
            sortStr = @"best";
            break;
    }
    NSString *path = [self pathWithId:galleryObjectId withOption:@"comments" withId2:sortStr];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * jsonArray = responseObject;
        NSMutableArray * comments = [NSMutableArray new];
        
        for(NSDictionary * json in jsonArray){
            
            NSError *JSONError = nil;
            IMGComment * comment = [[IMGComment alloc] initWithJSONObject:json error:&JSONError];
            if(!JSONError)
                [comments addObject:comment];
        }
        if(success)
            success(comments);
        
    } failure:failure];
}

#pragma mark - Submit Gallery Objects

+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    return [self submitImageWithID:imageID title:title terms:YES success:success failure:failure];
}

+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title terms:(BOOL)terms success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"image" withId2:imageID];
    
    NSDictionary *parameters = @{@"title":title , @"terms": [NSNumber numberWithBool:terms]};
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(imageID);
    } failure:failure];
}

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    return [self submitAlbumWithID:albumID title:title terms:YES success:success failure:failure];
}

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title terms:(BOOL)terms success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"album" withId2:albumID];
    
    NSDictionary *parameters = @{@"title":title , @"terms": [NSNumber numberWithBool:terms]};
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(albumID);
        
    } failure:failure];
}

#pragma mark - Remove Gallery objects

+ (void)removeImageWithID:(NSString *)imageID success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:imageID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(imageID);
        
    } failure:failure];
}

+ (void)removeAlbumWithID:(NSString *)albumID success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        if(success)
            success(albumID);
    } failure:failure];
}

#pragma mark - Voting/Reporting

+ (void)reportWithId:(NSString *)galleryObjectId success:(void (^)())success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithId:galleryObjectId withOption:@"report"];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

+ (void)voteWithId:(NSString *)galleryObjectId withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithId:galleryObjectId withOption:@"vote" withId2:[IMGModel strForVote:vote]];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

@end
