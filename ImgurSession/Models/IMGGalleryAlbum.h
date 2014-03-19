//
//  IMGGalleryAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGAlbum.h"

#import "IMGVote.h"


/**
 Model object class to represent albums posted to the gallery. https://api.imgur.com/models/gallery_album
 */
@interface IMGGalleryAlbum : IMGBasicAlbum

@property (nonatomic, readonly) NSInteger ups;
@property (nonatomic, readonly) NSInteger downs;
@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSInteger isAlbum;
@property (nonatomic, readonly) IMGVoteType vote;
@property (nonatomic, readonly) BOOL favorite;
@property (nonatomic, readonly) BOOL nsfw;
@property (nonatomic, readonly) NSString *section;


@end
