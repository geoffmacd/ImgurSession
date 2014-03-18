//
//  IMGGalleryImage.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGImage.h"


/**
 Model object class to represent images that are posted to the Imgur Gallery. Can be a part of an album. https://api.imgur.com/models/gallery_image 
 */
@interface IMGGalleryImage : IMGImage

@property (nonatomic, readonly) IMGVoteType vote;

@property (nonatomic, readonly) NSString *accountURL;

@property (nonatomic, readonly) NSInteger ups;
@property (nonatomic, readonly) NSInteger downs;
@property (nonatomic, readonly) NSInteger score;

@property (nonatomic, readonly) BOOL isAlbum;


@property (nonatomic, readonly) BOOL favorite;
@property (nonatomic, readonly) BOOL nsfw;

@end
