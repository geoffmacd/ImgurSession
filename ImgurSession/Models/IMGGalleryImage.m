//
//  IMGGalleryImage.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGGalleryImage.h"


@implementation IMGGalleryImage;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    self = [super initWithJSONObject:jsonData error:error];
    
    if(self && !*error) {
        
        _accountURL = jsonData[@"account_url"];
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
        _score = [jsonData[@"score"] integerValue];
        _isAlbum = [jsonData[@"is_album"] boolValue];
        if(![jsonData[@"vote"] isKindOfClass:[NSNull class]])
            _vote = [IMGVote voteForStr:jsonData[@"vote"]];
        
        if(![jsonData[@"nsfw"] isKindOfClass:[NSNull class]])
            _nsfw = [jsonData[@"nsfw"] boolValue];
        if(![jsonData[@"favorite"] isKindOfClass:[NSNull class]])
            _favorite = [jsonData[@"favorite"] boolValue];
    }
    return [self trackModels];
}


#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:
            @"%@; accountURL: \"%@\"; ups: %ld; downs: %ld; score: %ld; vote: %ld",
            [super description], self.accountURL, (long)self.ups, (long)self.downs, (long)self.score, (long)self.vote];
}


@end
