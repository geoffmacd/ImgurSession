//
//  ImgurPartialAlbum.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 24/07/13.
//  Distributed under the MIT license.
//

#import "IMGBasicAlbum.h"
#import "IMGImage.h"

@implementation IMGBasicAlbum;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        _albumID = jsonData[@"id"];
        _title = jsonData[@"title"];
        _description = jsonData[@"description"];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _cover = jsonData[@"cover"];
        if(_cover && ![_cover isKindOfClass:[NSNull class]]){
            _coverHeight = [jsonData[@"cover_height"] integerValue];
            _coverWidth = [jsonData[@"cover_width"] integerValue];
        }
        _accountURL = jsonData[@"account_url"];
        _privacy = jsonData[@"privacy"];
        _layout = [IMGBasicAlbum layoutForStr:jsonData[@"layout"]];
        _views = [jsonData[@"views"] integerValue];
        _link = [NSURL URLWithString:jsonData[@"link"]];
        _imagesCount = [jsonData[@"images_count"] integerValue];
        
        //intrepret images if available
        NSMutableArray * images = [NSMutableArray new];
        for(NSDictionary * imageJSON in jsonData[@"images"]){
            
            NSError *JSONError = nil;
            IMGImage * image = [[IMGImage alloc] initWithJSONObject:imageJSON error:&JSONError];
            
            if(!JSONError){
                [images addObject:image];
            }
        }
        _images = images;
    }
    return [self trackModels];
}

#pragma mark - Album Layout setting

+(NSString*)strForLayout:(IMGAlbumLayout)layoutType{
    switch (layoutType) {
        case IMGBlogLayout:
            return @"blog";
            break;
        case IMGGridLayout:
            return @"grid";
            break;
        case IMGHorizontalLayout:
            return @"horizontal";
            break;
        case IMGVerticalLayout:
            return @"vertical";
            break;
            
        default:
            return nil;
            break;
    }
}

+(IMGAlbumLayout)layoutForStr:(NSString*)layoutStr{
    if([[layoutStr lowercaseString] isEqualToString:@"default"])
        return IMGDefaultLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"blog"])
        return IMGBlogLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"grid"])
        return IMGGridLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"horizontal"])
        return IMGHorizontalLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"vertical"])
        return IMGVerticalLayout;
    return IMGDefaultLayout;
}

#pragma mark - Album Privacy setting

+(NSString*)strForPrivacy:(IMGAlbumPrivacy)privacy{
    switch (privacy) {
        case IMGAlbumPublic:
            return @"public";
            break;
        case IMGAlbumHidden:
            return @"hidden";
            break;
        case IMGAlbumSecret:
            return @"secret";
            break;
            
        default:
            break;
    }
}

+(IMGAlbumPrivacy)privacyForStr:(NSString*)privacyStr{
    if([[privacyStr lowercaseString] isEqualToString:@"public"])
        return IMGAlbumPublic;
    else if([[privacyStr lowercaseString] isEqualToString:@"hidden"])
        return IMGAlbumHidden;
    else if([[privacyStr lowercaseString] isEqualToString:@"secret"])
        return IMGAlbumSecret;
    return IMGAlbumSecret;
}



#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat: @"%@; albumId:  \"%@\"; title: \"%@\"; datetime: %@; cover: %@; accountURL: \"%@\"; privacy: %@; layout: %@; views: %ld; link: %@; imagesCount: %ld",  [super description], self.albumID, self.title,  self.datetime, self.cover, self.accountURL, self.privacy, [IMGBasicAlbum strForLayout:self.layout], (long)self.views, self.link, (long)self.imagesCount];
}

@end
