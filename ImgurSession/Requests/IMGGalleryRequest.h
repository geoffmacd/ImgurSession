//  IMGGalleryRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"


@class IMGGalleryAlbum,IMGGalleryImage,IMGGalleryProfile;

typedef NS_ENUM(NSInteger, IMGGallerySectionType) {
    IMGGallerySectionTypeHot,
    IMGGallerySectionTypeTop,
    IMGGallerySectionTypeUser
};

typedef NS_ENUM(NSInteger, IMGTopGalleryWindow) {
    IMGTopGalleryWindowDay, //default
    IMGTopGalleryWindowWeek,
    IMGTopGalleryWindowMonth,
    IMGTopGalleryWindowYear,
    IMGTopGalleryWindowAll
};


@interface IMGGalleryRequest : IMGEndpoint


#pragma mark - Gallery Load

+(void)hotGalleryPage:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+(void)hotGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+(void)userGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort showViral:(BOOL)showViral success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+(void)galleryWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark - Submit Image
+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title success:(void (^)(NSString *imageID))success failure:(void (^)(NSError *error))failure;
+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title terms:(BOOL)terms success:(void (^)(NSString *imageID))success failure:(void (^)(NSError *error))failure;

#pragma mark - Load Gallery image
+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGGalleryImage *image))success failure:(void (^)(NSError *error))failure;

#pragma mark - Remove Gallery image
+ (void)removeImageWithID:(NSString *)imageID success:(void (^)(NSString *imageID))success failure:(void (^)(NSError *error))failure;

#pragma mark - Submit Gallery Album

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title success:(void (^)(NSString *albumID))success failure:(void (^)(NSError *error))failure;
+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title terms:(BOOL)terms success:(void (^)(NSString *albumID))success failure:(void (^)(NSError *error))failure;

#pragma mark - Load Gallery album

+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGGalleryAlbum *album))success failure:(void (^)(NSError *error))failure;

#pragma mark - Remove gallery album

+ (void)removeAlbumWithID:(NSString *)albumID success:(void (^)(NSString *albumID))success failure:(void (^)(NSError *error))failure;

@end
