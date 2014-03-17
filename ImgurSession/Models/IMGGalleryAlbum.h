//
//  IMGGalleryAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGAlbum.h"


/**
 Model object class to represent albums posted to the gallery. https://api.imgur.com/models/gallery_album
 */
@interface IMGGalleryAlbum : IMGAlbum

@property (nonatomic, readonly) NSInteger ups;
@property (nonatomic, readonly) NSInteger downs;
@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSInteger isAlbum;
@property (nonatomic, readonly) NSString *vote;


@end
