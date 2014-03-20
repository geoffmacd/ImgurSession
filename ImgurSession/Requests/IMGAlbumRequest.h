//
//  IMGAlbumRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

#import "IMGBasicAlbum.h"

@class IMGAlbum,IMGImage;


/**
 Album requests. https://api.imgur.com/endpoints/album
 */
@interface IMGAlbumRequest : IMGEndpoint

#pragma mark - Load

+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGAlbum *album))success failure:(void (^)(NSError *error))failure;

#pragma mark - Create

+ (void)createAlbumWithTitle:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs success:(void (^)(IMGAlbum *album))success failure:(void (^)(NSError *error))failure;
+ (void)createAlbumWithTitle:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(IMGImage *)cover success:(void (^)(IMGAlbum *album))success failure:(void (^)(NSError *error))failure;

#pragma mark - Delete

+ (void)deleteAlbumWithID:(NSString *)albumID success:(void (^)())success failure:(void (^)(NSError *error))failure;



@end
