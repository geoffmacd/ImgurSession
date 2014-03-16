//
//  IMGAccountRequest.h
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"
#import "IMGSession.h"

@class IMGAccount,IMGAccountSettings,IMGAlbum,IMGImage,IMGComment,IMGGalleryProfile;

/**
 Account requests. https://api.imgur.com/endpoints/account
 */
@interface IMGAccountRequest : IMGEndpoint


#pragma mark - Load
/**
 Request standard user information. If you need the username for the account that is logged in, it is returned in the request for an access token.
 @param username username to fetch
 @return signal with request
 */
+ (void)accountWithUsername:(NSString *)username success:(void (^)(IMGAccount *account))success failure:(void (^)(NSError *error))failure;

#pragma mark - Favourites
/**
 Return the images the user has favorited in the gallery.
 @param username name of account
 @return signal with request
 */
+ (void)accountGalleryFavourites:(NSString *)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Returns the users favorited images, only accessible if you're logged in as the user.
 @return signal with request
 */
+ (void)accountFavourites:(NSString *)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark - Gallery Profile
/**
 Returns the totals for the gallery profile.
 @param username name of account
 @return signal with request
 */
+ (void)accountGalleryProfile:(NSString *)username success:(void (^)(IMGGalleryProfile *))success failure:(void (^)(NSError *))failure;

#pragma mark - Submissions
/**
 Retrieve account submissions.
 @param page pagination, page number to retrieve
 @param username name of account
 @return signal with request
 */
+ (void)accountSubmissionsPage:(NSInteger)page withUsername:(NSString*)username  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;


#pragma mark - Load settings
/**
 Retrieve account settings only for "me"
 @return signal with request
 */
+ (void)accountSettings:(void (^)(IMGAccountSettings *settings))success failure:(void (^)(NSError *error))failure;

#pragma mark - Update settings
/**
 Update account settings with new values
 */
+ (void)changeAccountWithBio:(NSString*)bio success:(void (^)())success failure:(void (^)(NSError *error))failure;

+ (void)changeAccountWithBio:(NSString*)bio messagingEnabled:(BOOL)msgEnabled publicImages:(BOOL)publicImages albumPrivacy:(IMGAlbumPrivacy)privacy acceptedGalleryTerms:(BOOL)galTerms success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Albums associated with account

/**
 Get all the albums associated with the account. Must be logged in as the user to see secret and hidden albums.
 */
+ (void)accountAlbumsWithUsername:(NSString*)username withPage:(NSInteger)page  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Get additional information about an album, this endpoint works the same as the Album Endpoint. You can also use any of the additional routes that are used on an album in the album endpoint.
 */
+ (void)accountAlbumWithId:(NSString*)albumId success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure;
/**
 Return an array of all of the album IDs.
 */
+ (void)accountAlbumIds:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Return the total number of albums associated with the account.
 */
+ (void)accountAlbumCount:(NSString*)username success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure;
/**
 Delete an Album with a given id.
 */
+ (void)accountDeleteAlbumWithID:(NSString*)albumId withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;



#pragma mark - Images associated with account

/**
 Return all of the images associated with the account. You can page through the images by setting the page, this defaults to 0.
 */
+ (void)accountImagesWithUsername:(NSString*)username withPage:(NSInteger)page  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Return information about a specific image. This endpoint works the same as the Image Endpoint. You can use any of the additional actions that the image endpoint with this endpoint.
 */
+ (void)accountImageWithId:(NSString*)imageId success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure;
/**
 Returns an array of Image IDs that are associated with the account..
 */
+ (void)accountImageIds:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Returns the total number of images associated with the account.
 */
+ (void)accountImageCount:(NSString*)username success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure;
/**
 Deletes an Image. This requires a delete hash rather than an ID.
 */
+ (void)accountDeleteImageWithHash:(NSString*)deleteHash withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;


#pragma mark - Comments associated with account

/**
 Return the comments the user has created.
 */
+ (void)accountCommentsWithUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Return information about a specific comment. This endpoint works the same as the Comment Endpoint. You can use any of the additional actions that the comment endpoint allows on this end point.
 */
+ (void)accountCommentWithId:(NSString*)commentId success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure;
/**
 Return an array of all of the comment IDs.
 */
+ (void)accountCommentIds:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Return a count of all of the comments associated with the account.
 */
+ (void)accountCommentCount:(NSString*)username success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure;
/**
 Delete a comment. You are required to be logged in as the user whom created the comment.
 */
+ (void)accountDeleteCommentWithId:(NSString*)commentId withUsername:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;


#pragma mark - Replies associated with account

/**
 Returns all of the reply notifications for the user. Required to be logged in as that user
 */
+ (void)accountReplies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+ (void)accountRepliesWithFresh:(BOOL)freshOnly success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
