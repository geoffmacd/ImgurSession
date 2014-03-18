//  IMGGalleryRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"


@class IMGGalleryAlbum,IMGGalleryImage,IMGGalleryProfile,IMGComment;

typedef NS_ENUM(NSInteger, IMGGallerySectionType) {
    IMGGallerySectionTypeHot, //default
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

typedef NS_ENUM(NSInteger, IMGGalleryCommentSortType) {
    IMGGalleryCommentSortBest, //default
    IMGGalleryCommentSortHot,
    IMGGalleryCommentSortNew
};

@interface IMGGalleryRequest : IMGEndpoint


#pragma mark - Load Gallery Pages

/**
 Retrieves same gallery as gooing to imgur.com. All params are default. Returns both gallery images and gallery albums.
 @param page    imgur pagination page to retrieve
 */
+(void)hotGalleryPage:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves same gallery as gooing to imgur.com. All params are default.
 @param page    imgur pagination page to retrieve
 @param viralSort    should sort by virality
 */
+(void)hotGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves same gallery as gooing to imgur.com. All params are default.
 @param page    imgur pagination page to retrieve
 @param window    imgur time period to retrieve. day,year,etc.
 @param viralSort    should sort by virality
 */
+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves user's gallery with viral options
 @param page    imgur pagination page to retrieve
 @param viralSort    should sort by virality
 @param showViral    show viral
 */
+(void)userGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort showViral:(BOOL)showViral success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves gallery with parameters specified in dictionary
 @param parameters    dictionary of parameters to specify
 */
+(void)galleryWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark - Load Gallery objects

/**
 Retrieves gallery image with id
 @param imageID    image Id string as retrieved through gallery page call
 */
+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGGalleryImage *image))success failure:(void (^)(NSError *error))failure;
/**
 Retrieves gallery album with id
 @param albumID    album Id string as retrieved through gallery page call
 */
+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGGalleryAlbum *album))success failure:(void (^)(NSError *error))failure;

#pragma mark - Submit Gallery Objects

/**
 Submits gallery image with id
 @param imageId    imageId to submit to gallery
 @param title    title to append to top of imgur page
 */
+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title success:(void (^)())success failure:(void (^)(NSError *error))failure;
+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title terms:(BOOL)terms success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Submits gallery album with id
 @param albumID    albumID to submit to gallery
 @param title    title to append to top of imgur page
 */
+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title success:(void (^)())success failure:(void (^)(NSError *error))failure;
+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title terms:(BOOL)terms success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Remove Gallery objects

/**
 Removes gallery object from gallery
 @param albumID    albumID to remove from gallery
 */
+ (void)removeImageWithID:(NSString *)imageID success:(void (^)(NSString *imageID))success failure:(void (^)(NSError *error))failure;
+ (void)removeAlbumWithID:(NSString *)albumID success:(void (^)(NSString *albumID))success failure:(void (^)(NSError *error))failure;


#pragma mark - Voting/Reporting

/**
 Report gallery object ID as being offensive
 @param galleryObjectId    gallery object id string to report
 */
+ (void)reportWithId:(NSString *)galleryObjectId success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Vote on gallery object ID
 @param vote    vote type for user to vote on gallery object
 */
+ (void)voteWithId:(NSString *)galleryObjectId withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Comment Actions - IMGCommentRequest

/**
 Retrieves comments from gallery object
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 @param commentSort    sort comments by best, hot or new
 */
+ (void)commentsWithGalleryID:(NSString *)galleryObjectId withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves comment IDS from gallery object
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 @param commentSort    sort comments by best, hot or new
 */
+ (void)commentIDsWithGalleryID:(NSString *)galleryObjectId withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieve a comment with an ID from a gallery object
 @param commentId    comment ID to get
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 */
+ (void)commentWithId:(NSString *)commentId galleryID:(NSString *)galleryObjectId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 Submits a comment to a gallery object
 @param caption    comment to post
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 */
+ (void)submitComment:(NSString*)caption galleryID:(NSString *)galleryObjectId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves comments from gallery object
 @param caption    comment to post
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 @param parentCommentID    ID string of parent comment to post this comment to
 */
+ (void)replyToComment:(NSString*)caption galleryID:(NSString *)galleryObjectId parentComment:(NSString*)parentCommentID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 Delete a posted comment with an ID
 @param commentId    comment ID to get
 */
+ (void)deleteCommentWithId:(NSString *)commentId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves count of comments from gallery object
 @param galleryObjectId    ID string of gallery object to retrieve comment count from
 */
+ (void)commentCountWithGalleryID:(NSString *)galleryObjectId success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure;



@end
