//
//  IMGGalleryImage.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGImage.h"

#import "IMGVote.h"


/**
 Protocol to represent both IMGGalleryImage and IMGGalleryAlbum which contain similar information.
 */
@protocol IMGGalleryObjectProtocol <NSObject>

/**
 Is the object an an album
 */
-(BOOL)isAlbum;
/**
 Get the cover image representation of object
 */
-(IMGImage*)coverImage;
/**
 Has the user favorited the object, false if anon
 */
-(BOOL)isFavorite;
/**
 Is it safe for work?
 */
-(BOOL)isNSFW;
/**
 The user's vote for the object, if authenticated
 */
-(IMGVoteType)usersVote;
/**
 ID for the gallery object
 */
-(NSString*)objectID;
/**
 Title of object
 */
-(NSString*)title;
/**
 ID of cover Image
 */
-(NSString*)coverID;
/**
 Score
 */
-(NSInteger)score;
/**
 Ups
 */
-(NSInteger)ups;
/**
 downs
 */
-(NSInteger)downs;
/**
 Views
 */
-(NSInteger)views;
/**
 Bandwidth
 */
-(NSInteger)bandwidth;
/**
 description
 */
-(NSString*)galleryDescription;
/**
 section
 */
-(NSString*)section;
/**
 Username who submitted this gallery image or album.
 */
-(NSString*)fromUsername;

@end


/**
 Model object class to represent images that are posted to the Imgur Gallery. Can be a part of an album. https://api.imgur.com/models/gallery_image 
 */
@interface IMGGalleryImage : IMGImage <IMGGalleryObjectProtocol>

@property (nonatomic, readonly) IMGVoteType vote;

@property (nonatomic, readonly, copy) NSString *accountURL;

@property (nonatomic, readonly) NSInteger ups;
@property (nonatomic, readonly) NSInteger downs;
@property (nonatomic, readonly) NSInteger score;


@property (nonatomic, readonly) BOOL favorite;
@property (nonatomic, readonly) BOOL nsfw;

@end
