//
//  IMGImage.h
//  ImgurKit
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGModel.h"

FOUNDATION_EXPORT NSString * const IMGUploadedImagesKey;

typedef NS_ENUM(NSInteger, ImgurSize) {
    ImgurSmallSquareSize,
    ImgurBigSquareSize,
    ImgurSmallThumbnailSize,
    ImgurMediumThumbnailSize,
    ImgurLargeThumbnailSize,
    ImgurHugeThumbnailSize
};


/**
 Model object class to represent images posted to Imgur. https://api.imgur.com/models/image
 */
@interface IMGImage : IMGModel


@property (nonatomic, readonly) NSString *imageID;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *description;
@property (nonatomic, readonly) NSDate *datetime;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL animated;

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) NSInteger size;

@property (nonatomic, readonly) NSInteger views;
@property (nonatomic, readonly) NSInteger bandwidth;

@property (nonatomic, readonly) NSString *deletehash;
@property (nonatomic, readonly) NSString *section;
@property (nonatomic, readonly) NSString *link;


#pragma mark - Display

- (NSURL *)URLWithSize:(ImgurSize)size;

@end
