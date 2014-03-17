//
//  IMGAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGBasicAlbum.h"


/**
 Model object class to represent albums not posted to the gallery. https://api.imgur.com/models/album   
 */
@interface IMGAlbum : IMGBasicAlbum

/**
 Delete hash string
 */
@property (nonatomic, readonly) NSString *deletehash;



@end
