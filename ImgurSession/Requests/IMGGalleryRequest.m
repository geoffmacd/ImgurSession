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
#import "IMGSession.h"

@implementation IMGGalleryRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"gallery";
}

#pragma mark - Gallery Load

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
       
//        NSLog(@"%@", [responseObject description]);

    } failure:failure];
}



#pragma mark - Load

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

#pragma mark - Submit

+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    return [self submitImageWithID:imageID title:title terms:YES success:success failure:failure];
}

+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title terms:(BOOL)terms success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, [NSNumber numberWithBool:terms], nil]
                                                           forKeys:[NSArray arrayWithObjects:@"title", @"terms", nil]];
    
    NSString *path = [self pathWithOption:@"image" withId2:imageID];
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(imageID);
    } failure:failure];
}

#pragma mark - Remove

+ (void)removeImageWithID:(NSString *)imageID success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:imageID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    
        if(success)
            success(imageID);
        
    } failure:failure];
}

#pragma mark - Load

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

#pragma mark - Submit

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    return [self submitAlbumWithID:albumID title:title terms:YES success:success failure:failure];
}

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title terms:(BOOL)terms success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, [NSNumber numberWithBool:terms], nil]
                                                           forKeys:[NSArray arrayWithObjects:@"title", @"terms", nil]];
    
    NSString *path = [self pathWithOption:@"album" withId2:albumID];
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(albumID);
        
    } failure:failure];
}

#pragma mark - Remove

+ (void)removeAlbumWithID:(NSString *)albumID success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID];
    
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        if(success)
            success(albumID);
    } failure:failure];
}


@end
