//
//  IMGAlbumRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGAlbumRequest.h"
#import "IMGAlbum.h"
#import "IMGImage.h"
#import "IMGSession.h"

@implementation IMGAlbumRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"album";
}


#pragma mark - Load

+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
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

+ (void)albumImagesWithID:(NSString *)albumID success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID withOption:@"images"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSArray * jsonArray = responseObject[@"data"];
        __block NSMutableArray * images = [NSMutableArray new];
        
        [jsonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary * imageDict = obj;
            NSError *JSONError = nil;
            IMGImage * image = [[IMGImage alloc] initWithJSONObject:imageDict error:&JSONError];
            
            if(!JSONError)
                [images addObject:image];
        }];
        
        
        if(!responseObject) {
            if(success)
                success(images);
        }
        else {
            
            if(failure)
                failure(nil);
        }
        
    } failure:failure];
}

#pragma mark - Create

+ (void)createAlbumWithTitle:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    return [self createAlbumWithTitle:title description:description imageIDs:imageIDs privacy:IMGAlbumPublic layout:IMGDefaultLayout cover:nil success:success failure:failure];
}

+ (void)createAlbumWithTitle:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(IMGImage *)cover success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    // Adding used parameters:
    
    if(title != nil)
        [parameters setObject:title forKey:@"title"];
    if(description != nil)
        [parameters setObject:description forKey:@"description"];
    if(cover != nil)
        [parameters setObject:cover.imageID forKey:@"cover"];
    
    if(imageIDs != nil)
    {
        NSString *idsParameter = @"";
        for (IMGImage *imageID in imageIDs) {
            if([imageID isKindOfClass:[NSString class]])
                idsParameter = [NSString stringWithFormat:@"%@%@,", idsParameter, imageID];
            else
                @throw [NSException exceptionWithName:@"ImgurObjectTypeException"
                                               reason:@"Objects contained in this array should be of type NSString"
                                             userInfo:[NSDictionary dictionaryWithObject:imageIDs forKey:@"images"]];
        }
        
        // Removing the last comma, which is useless
        [parameters setObject:[idsParameter substringToIndex:[idsParameter length] - 1] forKey:@"ids"];
    }
    
    if(privacy != IMGBlogLayout){
        NSString *parameterValue = [IMGAlbum strForPrivacy:privacy];
        
        if(parameterValue)
            [parameters setObject:parameterValue forKey:@"privacy"];
    }
    if (layout != IMGDefaultLayout){
        NSString *parameterValue = [IMGAlbum strForLayout:layout];
        
        if(parameterValue)
            [parameters setObject:parameterValue forKey:@"layout"];
    }
    
    
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *JSONError = nil;
        IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
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


#pragma mark - Delete

+ (void)deleteAlbumWithID:(NSString *)albumID success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(albumID);
    } failure:failure];
}


@end
