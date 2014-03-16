//
//  IMGImageRequest.m
//  ImgurKit
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
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    [parameters setObject:@"file" forKey:@"type"];
    
    // Add used parameters
    
    if(title != nil)
        [parameters setObject:title forKey:@"title"];
    if(description != nil)
        [parameters setObject:description forKey:@"description"];
    if(albumID != nil)
        [parameters setObject:albumID forKey:@"album"];
    
    // Create the request with the file appended to the body
    
    __block NSError *fileAppendingError = nil;
    
    void (^appendFile)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURL name:@"image" error:&fileAppendingError];
    };
    
    
    
    // If there's a file appending error, we must abort and return the error
    
    if(fileAppendingError) {
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
    return [self uploadImageWithURL:url title:nil description:nil filename:nil andLinkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description filename:(NSString *)filename andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    [parameters setObject:[url absoluteString] forKey:@"image"];
    [parameters setObject:@"URL" forKey:@"type"];
    
    // Add used parameters
    
    if(title != nil)
        [parameters setObject:title forKey:@"title"];
    if(description != nil)
        [parameters setObject:description forKey:@"description"];
    if(filename != nil)
        [parameters setObject:filename forKey:@"filename"];
    if(albumID != nil)
        [parameters setObject:albumID forKey:@"album"];
    
    
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
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

#pragma mark - Upload multiples images

+ (void)uploadImagesWithFileURLs:(NSArray *)fileURLs success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    return [self uploadImagesWithFileURLs:fileURLs titles:nil descriptions:nil andLinkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImagesWithFileURLs:(NSArray *)fileURLs titles:(NSArray *)titles descriptions:(NSArray *)descriptions andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    __block NSInteger filesNumber = [fileURLs count];
    
    // Check for invalid number of values
    
    if( (titles != nil && filesNumber != [titles count]) && (descriptions != nil && filesNumber != [descriptions count]) ) {
        @throw [NSException exceptionWithName:@"ImgurArrayLengthException"
                                       reason:@"There should be as much titles and descriptions as file URLs (or set them to `nil`)"
                                     userInfo:@{ @"fileURLs": fileURLs,
                                                 @"titles": titles,
                                                 @"descriptions": descriptions }];
    }
    
    // Return a signal that handles all the upload process
    
    
    if(filesNumber > 0) {
        __block NSMutableArray *images = [NSMutableArray new];
        __block NSInteger count = 0;
        
        void (^__block uploadBlock)() = ^() {
            
            [self uploadImageWithFileURL:fileURLs[count] title:(titles ? titles[count] : nil) description:(descriptions ? descriptions[count] : nil) andLinkToAlbumWithID:albumID success:^(IMGImage *image) {
                
                //add  to response
                [images addObject:image];
                
                count++;
                
                if(count < filesNumber){
                    uploadBlock();
                }
                
            } failure:^(NSError *error) {
                
                failure(error);
            }];
        };
        
        uploadBlock();
    }
    
}

+ (void)uploadImagesWithURLs:(NSArray *)urls success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    return [self uploadImagesWithURLs:urls titles:nil descriptions:nil filenames:nil andLinkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImagesWithURLs:(NSArray *)urls titles:(NSArray *)titles descriptions:(NSArray *)descriptions filenames:(NSArray *)filenames andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSInteger imageCount = [urls count];
    
    // Check for invalid number of values
    
    if( (titles != nil && imageCount != [titles count]) && (descriptions != nil && imageCount != [descriptions count]) && (filenames != nil && imageCount != [filenames count]) ) {
        @throw [NSException exceptionWithName:@"ImgurArrayLengthException"
                                       reason:@"There should be as much titles, descriptions and filenames as file URLs (or set them to `nil`)"
                                     userInfo:@{ @"urls": urls,
                                                 @"titles": titles,
                                                 @"descriptions": descriptions,
                                                 @"filenames": filenames }];
    }
    
    if(imageCount > 0) {
        
        __block NSMutableArray *images = [NSMutableArray new];
        __block NSInteger count = 0;
        
        void (^uploadBlock)() = ^() {
            
            [self uploadImageWithURL:urls[count] title:(titles ? titles[count] : nil) description:(descriptions ? descriptions[count] : nil) filename:(filenames ? filenames[count] : nil) andLinkToAlbumWithID:albumID success:^(IMGImage *image) {
                
                //add  to response
                [images addObject:image];
                
                count++;
                
                if(count < imageCount){
                    uploadBlock();
                }
                
            } failure:^(NSError *error) {
                
                failure(error);
            }];
        };
        
        uploadBlock();
    }
}



#pragma mark - Delete

+ (void)deleteImageWithID:(NSString *)imageID success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:imageID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(imageID);
    } failure:failure];
}

@end
