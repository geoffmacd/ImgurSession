//
//  IMGObject.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-04-14.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

@class IMGImage;

#ifndef ImgurSession_IMGObject_h
#define ImgurSession_IMGObject_h

/**
 Protocol to represent both IMGGalleryImage and IMGGalleryAlbum which contain similar information.
 */
@protocol IMGObjectProtocol <NSObject>

/**
 Is the object an an album
 */
-(BOOL)isAlbum;
/**
 Get the cover image representation of object
 */
-(IMGImage*)coverImage;
/**
 ID for the  object
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
 Views
 */
-(NSInteger)views;
/**
 description
 */
-(NSString*)galleryDescription;

@end



#endif
