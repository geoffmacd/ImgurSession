//
//  IMGImage.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGImage.h"

@interface IMGImage ()

@property (readwrite,nonatomic) NSString *imageID;
@property (readwrite,nonatomic) NSString *title;
@property (readwrite,nonatomic) NSString * imageDescription;
@property (readwrite,nonatomic) NSDate *datetime;
@property (readwrite,nonatomic) NSString *type;
@property (readwrite,nonatomic) BOOL animated;
@property (readwrite,nonatomic) NSInteger width;
@property (readwrite,nonatomic) NSInteger height;
@property (readwrite,nonatomic) NSInteger size;
@property (readwrite,nonatomic) NSInteger views;
@property (readwrite,nonatomic) NSInteger bandwidth;
@property (readwrite,nonatomic) NSString *deletehash;
@property (readwrite,nonatomic) NSString *section;
@property (readwrite,nonatomic) NSString *url;

@end

@implementation IMGImage;

#pragma mark - Init With JSON

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _imageID = jsonData[@"id"];
        _title = jsonData[@"title"];
        _imageDescription = jsonData[@"description"];
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
        _url = jsonData[@"link"];
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

- (NSURL *)URLWithSize:(IMGSize)size{
    
    NSString *path = [self.url stringByDeletingPathExtension];
    NSString *extension = [self.url pathExtension];
    NSString *stringURL;
    
    switch (size) {
        case IMGSmallSquareSize:
            stringURL = [NSString stringWithFormat:@"%@s.%@", path, extension];
            break;
            
        case IMGBigSquareSize:
            stringURL = [NSString stringWithFormat:@"%@b.%@", path, extension];
            break;
            
        //keeps image proportions below, please use these for better looking design
            
        case IMGSmallThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@t.%@", path, extension];
            break;
            
        case IMGMediumThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@m.%@", path, extension];
            break;
            
        case IMGLargeThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@l.%@", path, extension];
            break;
            
        case IMGHugeThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@h.%@", path, extension];
            break;
            
        default:
            stringURL = [NSString stringWithFormat:@"%@m.%@", path, extension];
            return nil;
    }
    return [NSURL URLWithString:stringURL];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSUInteger width = [[decoder decodeObjectForKey:@"width"] integerValue];
    NSUInteger height = [[decoder decodeObjectForKey:@"height"] integerValue];
    NSUInteger views = [[decoder decodeObjectForKey:@"views"] integerValue];
    NSUInteger size = [[decoder decodeObjectForKey:@"size"] integerValue];
    NSUInteger bandwidth = [[decoder decodeObjectForKey:@"bandwidth"] integerValue];
    NSString * imageID = [decoder decodeObjectForKey:@"imageID"];
    NSString * url = [decoder decodeObjectForKey:@"url"];
    NSString * deletehash = [decoder decodeObjectForKey:@"deletehash"];
    NSString * title = [decoder decodeObjectForKey:@"title"];
    NSString * imageDescription = [decoder decodeObjectForKey:@"imageDescription"];
    NSString * type = [decoder decodeObjectForKey:@"type"];
    NSString * section = [decoder decodeObjectForKey:@"section"];
    NSDate *datetime = [decoder decodeObjectForKey:@"datetime"];
    BOOL animated  = [[decoder decodeObjectForKey:@"animated"] boolValue];
    
    if (self = [super init]) {
        _imageID = imageID;
        _imageDescription = imageDescription;
        _animated = animated;
        _height = height;
        _width = width;
        _views = views;
        _size = size;
        _section = section;
        _datetime = datetime;
        _type = type;
        _bandwidth = bandwidth;
        _deletehash = deletehash;
        _title = title;
        _url = url;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.imageID forKey:@"imageID"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.imageDescription forKey:@"imageDescription"];
    [coder encodeObject:self.section forKey:@"section"];
    [coder encodeObject:self.deletehash forKey:@"deletehash"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.datetime forKey:@"datetime"];
    
    [coder encodeObject:@(self.bandwidth) forKey:@"bandwidth"];
    [coder encodeObject:@(self.views) forKey:@"views"];
    [coder encodeObject:@(self.width) forKey:@"width"];
    [coder encodeObject:@(self.height) forKey:@"height"];
    [coder encodeObject:@(self.size) forKey:@"size"];
    [coder encodeObject:@(self.animated) forKey:@"animated"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGImage * copy = [[IMGImage alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setImageID:[self.imageID copyWithZone:zone]];
        [copy setImageDescription:[self.imageDescription copyWithZone:zone]];
        [copy setUrl:[self.url copyWithZone:zone]];
        [copy setDatetime:[self.datetime copyWithZone:zone]];
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setType:[self.type copyWithZone:zone]];
        [copy setSection:[self.section copyWithZone:zone]];
        [copy setDeletehash:[self.deletehash copyWithZone:zone]];
        
        // Set primitives
        [copy setWidth:self.width];
        [copy setHeight:self.height];
        [copy setViews:self.views];
        [copy setBandwidth:self.bandwidth];
        [copy setSize:self.size];
        [copy setAnimated:self.animated];
    }
    
    return copy;
}


@end
