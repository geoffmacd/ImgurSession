//
//  IMGImage.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGModel.h"    


/*
 There are 6 total thumbnails that an image can be resized to. Each one is accessable by appending a single character suffix to the end of the image id, and before the file extension. The thumbnails are:
 
 Thumbnail Suffix	Thumbnail Name	Thumbnail Size	Keeps Image Proportions
 s	Small Square	90x90	No
 b	Big Square	160x160	No
 t	Small Thumbnail	160x160	Yes
 m	Medium Thumbnail	320x320	Yes
 l	Large Thumbnail	640x640	Yes
 h	Huge Thumbnail	1024x1024	Yes
 For example, the image located at http://i.imgur.com/12345.jpg has the Medium Thumbnail located at http://i.imgur.com/12345m.jpg
 */
typedef NS_ENUM(NSInteger, IMGSize) {
    IMGSmallSquareSize,
    IMGBigSquareSize,
    IMGSmallThumbnailSize,
    IMGMediumThumbnailSize,
    IMGLargeThumbnailSize,
    IMGHugeThumbnailSize
};


/**
 Model object class to represent images posted to Imgur. https://api.imgur.com/models/image
 */
@interface IMGImage : IMGModel <NSCopying,NSCoding>

/**
 Image ID to reference in Imgur globally
 */
@property (nonatomic, readonly, copy) NSString *imageID;
/**
 Title of image. This is the heading on the imgur image page where the joke usually is.
 */
@property (nonatomic, readonly, copy) NSString *title;
/**
 Description of image. Never seen this filled out
 */
@property (nonatomic, readonly, copy) NSString * imageDescription;
/**
 Date image was submitted.
 */
@property (nonatomic, readonly) NSDate *datetime;
/**
 Type of image from HTTP header. JPEG/GIF, maybe other types
 */
@property (nonatomic, readonly, copy) NSString *type;
/**
 Is the image animated
 */
@property (nonatomic, readonly) BOOL animated;
/**
 Image width in px
 */
@property (nonatomic, readonly) CGFloat width;
/**
 Image height in px
 */
@property (nonatomic, readonly) CGFloat height;
/**
 Image size in bytes
 */
@property (nonatomic, readonly) NSInteger size;
/**
 Number of page impressions/image views on imgur
 */
@property (nonatomic, readonly) NSInteger views;
/**
 Image bandwidth transmitted to users in bytes
 */
@property (nonatomic, readonly) NSInteger bandwidth;
/**
 Hash to send DELETE request with to delete image when session is using anonymous authentication.
 */
@property (nonatomic, readonly, copy) NSString *deletehash;
/**
 Imgur section the image belongs to if applicable
 */
@property (nonatomic, readonly, copy) NSString *section;
/**
 URL to actual image file. Use URLWithSize to retrieve various image sizes.
 */
@property (nonatomic, readonly, copy) NSURL *url;


#pragma mark - Display

/**
 Retrieves various image sizes using the url with the letter specifier model as described at https://api.imgur.com/models/image
 @param size constant to specify requested image size
 @return URL for image of that size
 */
- (NSURL *)URLWithSize:(IMGSize)size;

@end
