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

/**
 Retrieve album details and images
 */
+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGAlbum *album))success failure:(void (^)(NSError *error))failure;

#pragma mark - Create

/**
 Create an album with an array of imageIDs which currently exist
 */
+ (void)createAlbumWithTitle:(NSString *)title imageIDs:(NSArray *)imageIDs success:(void (^)(NSString * albumID, NSString *albumDeleteHash))success failure:(void (^)(NSError *error))failure;
+ (void)createAlbumWithTitle:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(NSString *)coverID success:(void (^)(NSString * , NSString * albumDeleteHash))success failure:(void (^)(NSError *error))failure;

#pragma mark - Update

/**
 Update an existing album with optional params. If anonymous, use deletehash for album ID
 */
+ (void)updateAlbumWithID:(NSString*)albumID imageIDs:(NSArray *)imageIDs success:(void (^)())success failure:(void (^)(NSError *))failure;
+ (void)updateAlbumWithID:(NSString*)albumID title:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(NSString *)coverID success:(void (^)())success failure:(void (^)(NSError *))failure;

#pragma mark - Delete

/**
 Delete an album with an albumID if you are the owner of the album. For anonymous delete, you must pass the deletehash instead
 */
+ (void)deleteAlbumWithID:(NSString *)albumID success:(void (^)())success failure:(void (^)(NSError *error))failure;
+ (void)deleteAlbumWithDeleteHash:(NSString *)deletehash success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Favourite
/**
 Fav an album. Must be signed in.
 */
+(void)favouriteAlbumWithID:(NSString*)albumID  success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
