//
//  IMGImageRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

@class IMGImage;

/**
 Image requests. https://api.imgur.com/endpoints/image
 */
@interface IMGImageRequest : IMGEndpoint

#pragma mark - Load

/**
 Retrieves image info from imageID
 */
+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

#pragma mark - Upload one image

/**
 Upload an image with local image URL
 */
+ (void)uploadImageWithFileURL:(NSURL *)fileURL success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;
+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

/**
 Upload an image with an external image URL
 */
+ (void)uploadImageWithURL:(NSURL *)url success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;
+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

#pragma mark - Upload multiple images

/**
 Upload multiple images using image file url, title and description in NSDictionary in files and optionally link the images to an album
 */
+(void)uploadImages:(NSArray*)files toAlbumWithID:(NSString*)albumID success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+(void)uploadImages:(NSArray*)files success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark - Delete

/**
 Delete an image with an image ID if you are the owner of the image. For anonymous delete, you must pass the deletehash instead
 */
+ (void)deleteImageWithID:(NSString *)imageID success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Favourtie
/**
 Fav an album. Must be signed in.
 */
+(void)favouriteImageWithID:(NSString*)imageID  success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
