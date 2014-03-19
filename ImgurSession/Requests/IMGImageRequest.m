//
//  IMGImageRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGImageRequest.h"

#import "IMGSession.h"
#import "IMGImage.h"

@implementation IMGImageRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"image";
}

#pragma mark - Load

+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:imageID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
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

#pragma mark - Upload one image

+ (void)uploadImageWithFileURL:(NSURL *)fileURL success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    return [self uploadImageWithFileURL:fileURL title:nil description:nil andLinkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    //upload file from binary data
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"type"] = @"file";
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    if(albumID )
        parameters[@"album"] = albumID;
    
    // Create the request with the file appended to the body
    __block NSError *fileAppendingError = nil;
    
    void (^appendFile)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURL name:@"image" error:&fileAppendingError];
    };
    
    
    // If there's a file appending error, we must abort and return the error
    if(fileAppendingError){
        if(failure)
            failure(fileAppendingError);
        return;
    }
    
    //post
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters constructingBodyWithBlock:appendFile success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
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

+ (void)uploadImageWithURL:(NSURL *)url success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    return [self uploadImageWithURL:url title:nil description:nil andLinkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    //just upload with a url
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"image"] = [url absoluteString];
    parameters[@"name"] = [url lastPathComponent];
    parameters[@"type"] = @"URL";
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    if(albumID )
        parameters[@"album"] = albumID;
    
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError) {
            if(success)
                success(image);
        } else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Delete

+ (void)deleteImageWithID:(NSString *)imageID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:imageID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            
            success();
    } failure:failure];
}

@end
