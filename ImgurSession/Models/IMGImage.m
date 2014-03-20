//
//  IMGImage.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGImage.h"


NSString * const IMGUploadedImagesKey = @"IMGUploadedImages";


@interface IMGImage ()

@property (readwrite, nonatomic) NSString *title;
@property (readwrite, nonatomic) NSString *description;

@end

@implementation IMGImage;

#pragma mark - Init With JSON

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _imageID = jsonData[@"id"];
        _title = jsonData[@"title"];
        _description = jsonData[@"description"];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _type = jsonData[@"type"];
        _section = jsonData[@"section"];
        if(![jsonData[@"animated"] isKindOfClass:[NSNull class]])
            _animated = [jsonData[@"animated"] boolValue];
        _width = [jsonData[@"width"] integerValue];
        _height = [jsonData[@"height"] integerValue];
        _size = [jsonData[@"size"] integerValue];
        _views = [jsonData[@"views"] integerValue];
        _bandwidth = [jsonData[@"bandwidth"] integerValue];
        _deletehash = jsonData[@"deletehash"];
        _link = jsonData[@"link"];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:
            @"%@; image ID: %@ ; title: \"%@\"; datetime: %@; type: %@; animated: %d; width: %ld; height: %ld; size: %ld; views: %ld; bandwidth: %ld",
            [super description],  self.imageID, self.title, self.datetime, self.type, self.animated, (long)self.width, (long)self.height, (long)self.size, (long)self.views, (long)self.bandwidth];
}

#pragma mark - Display

- (NSURL *)URLWithSize:(ImgurSize)size
{
    NSString *stringURL = [self.link copy];
    NSString *path = [stringURL stringByDeletingPathExtension];
    NSString *extension = [stringURL pathExtension];
    
    switch (size) {
        case ImgurSmallSquareSize:
            stringURL = [NSString stringWithFormat:@"%@s.%@", path, extension];
            break;
            
        case ImgurBigSquareSize:
            stringURL = [NSString stringWithFormat:@"%@b.%@", path, extension];
            break;
            
        case ImgurSmallThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@t.%@", path, extension];
            break;
            
        case ImgurMediumThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@m.%@", path, extension];
            break;
            
        case ImgurLargeThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@l.%@", path, extension];
            break;
            
        case ImgurHugeThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@h.%@", path, extension];
            break;
            
        default:
            return nil;
    }
    return [NSURL URLWithString:stringURL];
}



@end
