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

+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

#pragma mark - Upload one image

+ (void)uploadImageWithFileURL:(NSURL *)fileURL success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;
+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

+ (void)uploadImageWithURL:(NSURL *)url success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;
+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;


#pragma mark - Delete

+ (void)deleteImageWithID:(NSString *)imageID success:(void (^)(NSString *imageID))success failure:(void (^)(NSError *error))failure;

@end
