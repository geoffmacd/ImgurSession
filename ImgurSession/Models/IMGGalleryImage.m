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
        
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
        _score = [jsonData[@"score"] integerValue];
        if(![jsonData[@"vote"] isKindOfClass:[NSNull class]])
            _vote = [IMGVote voteForStr:jsonData[@"vote"]];
        
        _accountURL = jsonData[@"account_url"];
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

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGGalleryImage class]]) {
        return NO;
    }
    return ([[object imageID] isEqualToString:self.imageID]);
}

#pragma mark - IMGGalleryObjectProtocol

-(BOOL)isAlbum{
    return NO;
}

-(IMGVoteType)usersVote{
    return self.vote;
}

-(BOOL)isFavorite{
    return self.favorite;
}

-(BOOL)isNSFW{
    return self.nsfw;
}

-(IMGImage *)coverImage{
    
    //for gallery image, the image is the cover image
    return self;
}

@end
