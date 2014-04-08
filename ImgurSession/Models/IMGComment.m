//
//  IMGComment.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGComment.h"

@implementation IMGComment

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"id"] || !jsonData[@"image_id"] || !jsonData[@"comment"]){
            
            *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        
        _commentID = [jsonData[@"id"] integerValue];
        _imageID = jsonData[@"image_id"];
        _caption = jsonData[@"comment"];
        _author = jsonData[@"author"];
        _authorID = [jsonData[@"author_id"] integerValue];
        _onAlbum = [jsonData[@"on_album"] boolValue];
        _albumCover = jsonData[@"album_cover"];
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
        _points = [jsonData[@"points"] integerValue];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _parentID = [jsonData[@"parent_id"] integerValue];
        _deleted = [jsonData[@"deleted"] boolValue];
        
        _children = jsonData[@"children"];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@; caption: \"%@\"; author: \"%@\"; authorId: %ld; imageId: %@;",  [super description], self.caption, self.author, (long)self.authorID, self.imageID];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGComment class]]) {
        return NO;
    }
    
    return ([object commentID] == self.commentID);
}


@end
