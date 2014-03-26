//
//  IMGGalleryAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGAlbum.h"

#import "IMGVote.h"
#import "IMGGalleryImage.h"


/**
 Model object class to represent albums posted to the gallery. https://api.imgur.com/models/gallery_album
 */
@interface IMGGalleryAlbum : IMGBasicAlbum <IMGGalleryObjectProtocol>

@property (nonatomic, readonly) IMGVoteType vote;

@property (nonatomic, readonly) NSInteger ups;
@property (nonatomic, readonly) NSInteger downs;
@property (nonatomic, readonly) NSInteger score;

@property (nonatomic, readonly, copy) NSString *section;
@property (nonatomic, readonly) BOOL favorite;
@property (nonatomic, readonly) BOOL nsfw;


@end
