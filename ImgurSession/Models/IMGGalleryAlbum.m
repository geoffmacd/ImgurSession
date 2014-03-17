//
//  IMGGalleryAlbum.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGGalleryAlbum.h"

@implementation IMGGalleryAlbum;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error
{
    self = [super initWithJSONObject:jsonData error:error];
    
    if(self && !*error) {
        
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
        _score = [jsonData[@"score"] integerValue];
        _isAlbum = [jsonData[@"is_album"] boolValue];
        _vote = jsonData[@"vote"];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description
{
    return [NSString stringWithFormat: @"%@; ups: %ld; downs: %ld; score: %ld; vote: %ld", [super description], (long)_ups, (long)_downs, (long)_score, (long)_vote];
}


@end
