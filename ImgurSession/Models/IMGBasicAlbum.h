//
//  ImgurPartialAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 24/07/13.
//  Distributed under the MIT license.
//

#import "IMGModel.h"


typedef NS_ENUM(NSUInteger, IMGAlbumPrivacy){
    IMGAlbumDefault = 0,
    IMGAlbumPublic = 0,
    IMGAlbumHidden,
    IMGAlbumSecret
};

typedef NS_ENUM(NSUInteger, IMGAlbumLayout){
    IMGDefaultLayout = 0,
    IMGBlogLayout = 0,
    IMGGridLayout,
    IMGHorizontalLayout,
    IMGVerticalLayout
};

/**
 Model object class to represent common denominator properties to gallery and user albums. https://api.imgur.com/models/album
 */
@interface IMGBasicAlbum : IMGModel

/**
 Album ID
 */
@property (nonatomic, readonly) NSString *albumID;
/**
 Title of album
 */
@property (nonatomic) NSString *title;
/**
 Album description
 */
@property (nonatomic) NSString *description;
/**
 Album creation date
 */
@property (nonatomic, readonly) NSDate *datetime;
/**
 Image Id for cover of album
 */
@property (nonatomic) NSString *cover;
/**
 Cover image width in px
 */
@property (nonatomic, readonly) NSInteger coverWidth;
/**
 Cover image height in px
 */
@property (nonatomic, readonly) NSInteger coverHeight;
/**
 account username of album creator, not a URL biut named lIMGe this anyway. nil if anonymous
 */
@property (nonatomic, readonly) NSString *accountURL;
/**
 Privacy of album
 */
@property (nonatomic) NSString *privacy;
/**
 Type of layout for album
 */
@property (nonatomic) IMGAlbumLayout layout;
/**
 Number of views for album
 */
@property (nonatomic, readonly) NSInteger views;
/**
 URL for album link
 */
@property (nonatomic, readonly) NSURL *link;
/**
 Number of images in album
 */
@property (nonatomic, readonly) NSInteger imagesCount; // Optional: can be set to nil
/**
 Array of images in IMGImage form
 */
@property (nonatomic) NSArray *images; // Optional: can be set to nil



#pragma mark - Album Layout setting
/**
 @param layoutType layout constant
 @return string for layout constant
 */
+(NSString*)strForLayout:(IMGAlbumLayout)layoutType;

/**
 @param string for layout constant
 @return layout layout constant
 */
+(IMGAlbumLayout)layoutForStr:(NSString*)layoutStr;

#pragma mark - Album Privacy setting
/**
 @param privacy privacy constant
 @return string for privacy constant
 */
+(NSString*)strForPrivacy:(IMGAlbumPrivacy)privacy;

/**
 @param string for privacy constant
 @return privacy privacy constant
 */
+(IMGAlbumPrivacy)privacyForStr:(NSString*)privacyStr;


@end
