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
        if(![jsonData[@"vote"] isKindOfClass:[NSNull class]])
            _vote = [IMGVote voteForStr:jsonData[@"vote"]];
        
        _section = jsonData[@"section"];
        if(![jsonData[@"nsfw"] isKindOfClass:[NSNull class]])
            _nsfw = [jsonData[@"nsfw"] boolValue];
        if(![jsonData[@"favorite"] isKindOfClass:[NSNull class]])
            _favorite = [jsonData[@"favorite"] boolValue];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description
{
    return [NSString stringWithFormat: @"%@; ups: %ld; downs: %ld; score: %ld; vote: %ld", [super description], (long)self.ups, (long)self.downs, (long)self.score, (long)self.vote];
}

#pragma mark - IMGGalleryObjectProtocol

-(BOOL)isAlbum{
    return YES;
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
    
    //image should be included in the images array
    __block IMGImage * cover;
    
    [self.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IMGImage * img = obj;
        
        if([self.coverID isEqualToString:img.imageID]){
            //this is the cover
            cover = img;
            *stop = YES;
        }
    }];
    
    if(!cover)
        NSLog(@"No cover image found for album");
    
    return cover;
}

@end
