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
        
        if(!JSONError && image) {
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
    
    [self uploadImageWithFileURL:fileURL title:nil description:nil linkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
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
        
        if(!JSONError && image) {
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
    return [self uploadImageWithURL:url title:nil description:nil linkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
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
        
        if(!JSONError && image) {
            if(success)
                success(image);
        } else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Upload multiple images

+(void)uploadImages:(NSArray*)files success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    [self uploadImages:files toAlbumWithID:nil success:success failure:failure];
}

+(void)uploadImages:(NSArray*)files toAlbumWithID:(NSString*)albumID success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSParameterAssert(files);
    
    //async invocation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //keep track of multiple file uploads with semaphore
        dispatch_semaphore_t sema = dispatch_semaphore_create([files count]);
        //return images
        __block NSMutableArray * images = [NSMutableArray new];
        
        for(NSDictionary * file in files){
            
            //expects titles and files and descriptions
            NSParameterAssert(file[@"title"]);
            NSParameterAssert(file[@"description"]);
            NSParameterAssert(file[@"imageURL"]);
            
            [self uploadImageWithFileURL:file[@"title"] title:file[@"title"] description:file[@"title"] linkToAlbumWithID:albumID success:^(IMGImage *image) {
                
                [images addObject:image];
                
                dispatch_semaphore_signal(sema);
                
            } failure:^(NSError *error) {
                
                dispatch_semaphore_signal(sema);
            }];
        }
        
        //waits until above is completed
        if(dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)){
            //fails if return is non-zero
            if(failure)
                failure([NSError errorWithDomain:@"ImgurSession" code:14 userInfo:nil]);
        } else if(success){
            success([NSArray arrayWithArray:images]);
        }
    });
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
