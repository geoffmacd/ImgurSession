//
//  IMGAccountRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGAccountRequest.h"
#import "IMGAccount.h"
#import "IMGAccountSettings.h"
#import "IMGAlbum.h"
#import "IMGGalleryAlbum.h"
#import "IMGGalleryImage.h"
#import "IMGGalleryProfile.h"
#import "IMGNotification.h"
#import "IMGComment.h"

@implementation IMGAccountRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"account";
}

#pragma mark - Load

+ (void)accountWithUsername:(NSString *)username success:(void (^)(IMGAccount *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username];
    
    
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGAccount *account = [[IMGAccount alloc] initWithJSONObject:responseObject withName:username error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(account);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Favourites

+ (void)accountGalleryFavourites:(NSString *)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"gallery_favorites"];
    
    
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * favImagesJSON = responseObject;
        NSMutableArray * favImages = [NSMutableArray new];
        
        for(NSDictionary * imageJSON in favImagesJSON){
            JSONError = nil;
            
            IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:imageJSON error:&JSONError];
            
            if(JSONError){
                
                if(failure)
                    failure(JSONError);
            } else {
                [favImages addObject:image];
            }
        }
        
        if(success)
            success(favImages);
        
    } failure:failure];
}

+ (void)accountFavourites:(NSString *)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"favorites"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * fullJSON = responseObject;
        NSMutableArray * favs = [NSMutableArray new];
        
        //could be gallery image or gallery album
        for(NSDictionary * json in fullJSON){
            JSONError = nil;
            
            //album
            if(json[@"layout"]){
                
                IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:json error:&JSONError];
                if(JSONError){
                    
                    if(failure)
                        failure(JSONError);
                } else {
                    [favs addObject:album];
                }
            } else {
                //image
                IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:json error:&JSONError];
                
                if(JSONError){
                
                    if(failure)
                        failure(JSONError);
                } else {
                    [favs addObject:image];
                }
            }
        }
        
        if(success)
            success(favs);
        
    } failure:failure];
}

+ (void)accountSubmissionsPage:(NSInteger)page withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"submissions" withId2:[NSString stringWithFormat:@"%ld",(long)page]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * fullJSON = responseObject;
        NSMutableArray * submissionsPage = [NSMutableArray new];
        
        //could be gallery image or gallery album
        for(NSDictionary * json in fullJSON){
            JSONError = nil;
            
            //album
            if(json[@"layout"]){
                
                IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:json error:&JSONError];
                if(JSONError){
                    
                    if(failure)
                        failure(JSONError);
                } else {
                    [submissionsPage addObject:album];
                }
            } else {
                //image
                IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:json error:&JSONError];
                
                if(JSONError){
                    if(failure)
                        failure(JSONError);
                } else {
                    [submissionsPage addObject:image];
                }
            }
        }
        
        if(success)
            success(submissionsPage);
        
    } failure:failure];
}

#pragma mark - Load account settings

+ (void)accountSettings:(void (^)(IMGAccountSettings *settings))success failure:(void (^)(NSError *error))failure{
    //only allows settings for current account after login
    NSString *path = [self pathWithId:@"me" withOption:@"settings"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGAccountSettings *settings = [[IMGAccountSettings alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(settings);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Update account settings

+ (void)changeAccountWithBio:(NSString*)bio success:(void (^)())success failure:(void (^)(NSError *error))failure{
    //only allows settings for current account after login
    NSString *path = [self pathWithId:@"me" withOption:@"settings"];
    
    NSDictionary * params = @{@"bio":bio};
    
    //put or post
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

+ (void)changeAccountWithBio:(NSString*)bio messagingEnabled:(BOOL)msgEnabled publicImages:(BOOL)publicImages albumPrivacy:(IMGAlbumPrivacy)privacy acceptedGalleryTerms:(BOOL)galTerms success:(void (^)())success failure:(void (^)(NSError *error))failure{
    //only allows settings for current account after login
    NSString *path = [self pathWithId:@"me" withOption:@"settings"];
    
    NSDictionary * params = @{@"bio":bio,@"public_images":[NSNumber numberWithBool:publicImages],@"messaging_enabled":[NSNumber numberWithBool:msgEnabled],@"album_privacy":[IMGBasicAlbum strForPrivacy:privacy],@"accepted_gallery_terms":[NSNumber numberWithBool:galTerms]};
    
    //put or post
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Gallery Profile

+ (void)accountGalleryProfile:(NSString *)username success:(void (^)(IMGGalleryProfile *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"gallery_profile"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGGalleryProfile *profile = [[IMGGalleryProfile alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(profile);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Albums associated with account

+ (void)accountAlbumsWithUsername:(NSString*)username withPage:(NSInteger)page  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"albums" withId2:[NSString stringWithFormat:@"%ld",(long)page]];

    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * accountAlbumsJSON = responseObject;
        NSMutableArray * accountAlbums = [NSMutableArray new];
        
        for(NSDictionary * albumJSON in accountAlbumsJSON){
            JSONError = nil;
            
            IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:albumJSON error:&JSONError];
            
            if(JSONError){
                
                if(failure)
                    failure(JSONError);
            } else {
                [accountAlbums addObject:album];
            }
        }
        
        if(success)
            success(accountAlbums);
        
    } failure:failure];
}

+ (void)accountAlbumWithId:(NSString*)albumId success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    [IMGAlbumRequest albumWithID:albumId success:success failure:failure];
}

+ (void)accountAlbumIds:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"albums/ids"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * albumIds = responseObject;
        
        if(success)
            success(albumIds);
        
    } failure:failure];
    
    
}

+ (void)accountAlbumCount:(NSString*)username success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"albums/count"];

    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numAccountAlbums = responseObject; //NSNumber??
        
        if(success)
            success(numAccountAlbums);
        
    } failure:failure];
    
}

+ (void)accountDeleteAlbumWithID:(NSString*)albumId withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"albums" withId2:albumId];

    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(nil);
        
    } failure:failure];
}


#pragma mark - Images associated with account


+ (void)accountImagesWithUsername:(NSString*)username withPage:(NSInteger)page  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"images" withId2:[NSString stringWithFormat:@"%ld",(long)page]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * accountAlbumsJSON = responseObject;
        NSMutableArray * accountAlbums = [NSMutableArray new];
        
        for(NSDictionary * albumJSON in accountAlbumsJSON){
            JSONError = nil;
            
            IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:albumJSON error:&JSONError];
            
            if(JSONError){
                if(failure)
                    failure(JSONError);
            } else {
                [accountAlbums addObject:album];
            }
        }
    
        if(success)
            success(accountAlbums);
        
    } failure:failure];
}

+ (void)accountImageWithId:(NSString*)imageId success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    
    [IMGImageRequest imageWithID:imageId success:success failure:failure];
}

+ (void)accountImageIds:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"images/ids"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * albumIds = responseObject;
        if(success)
            success(albumIds);
        
    } failure:failure];
}

+ (void)accountImageCount:(NSString*)username success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"images/count"];
   
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numAccountAlbums = responseObject; //NSNumber??
        if(success)
            success(numAccountAlbums);
        
    } failure:failure];
}

+ (void)accountDeleteImageWithHash:(NSString*)deleteHash withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:username withOption:@"image" withId2:deleteHash];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    
        if(success)
            success(nil);
        
    } failure:failure];
}


#pragma mark - Comments associated with account


+ (void)accountCommentsWithUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"comments"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * commentsJSON = responseObject;
        NSMutableArray * comments = [NSMutableArray new];
        
        for(NSDictionary * commentJSON in commentsJSON){
            JSONError = nil;
            
            IMGComment *comment = [[IMGComment alloc] initWithJSONObject:commentJSON error:&JSONError];
            
            if(JSONError){
        
                if(failure)
                    failure(JSONError);
            } else {
                [comments addObject:comment];
            }
        }
        
        if(success)
            success(comments);
        
    } failure:failure];
}

+ (void)accountCommentWithId:(NSString*)commentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    
    [IMGCommentRequest commentWithId:commentId withReplies:NO success:success failure:failure];
}

+ (void)accountCommentIds:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"comments/ids"];
    
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * albumIds = responseObject;
        
        if(success)
            success(albumIds);
        
    } failure:failure];
}

+ (void)accountCommentCount:(NSString*)username success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"comments/count"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numAccountAlbums = responseObject; //NSNumber??
        
        if(success)
            success(numAccountAlbums);
        
    } failure:failure];
}

+ (void)accountDeleteCommentWithId:(NSString*)commentId withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:username withOption:@"comment" withId2:commentId];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(nil);
        
    } failure:failure];
}


#pragma mark - Replies associated with account

+ (void)accountReplies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    //fresh replies only
    [self accountRepliesWithFresh:YES success:success failure:failure];
}

+ (void)accountRepliesWithFresh:(BOOL)freshOnly success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithId:@"me" withOption:@"notifications/replies"];
    
    NSDictionary * params = @{@"new":[NSNumber numberWithBool:freshOnly]};
    
    [[IMGSession sharedInstance] GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * notificationsJSON = responseObject;
        NSMutableArray * notifications = [NSMutableArray new];
        
        for(NSDictionary * notificationJSON in notificationsJSON){
            JSONError = nil;
            
            IMGNotification * notification;
            //is it a reply or message
            if(notificationJSON[@"caption"]){
                //reply
                notification = [[IMGNotification alloc] initMessageNotificationWithJSONObject:responseObject error:&JSONError];
            } else {
                //message
                notification = [[IMGNotification alloc] initMessageNotificationWithJSONObject:responseObject error:&JSONError];
            }
            
            if(JSONError){
                if(failure)
                    failure(JSONError);
            } else {
                [notifications addObject:notification];
            }
        }
        
        if(success)
            success(notifications);
        
    } failure:failure];
}


@end
