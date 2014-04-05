//
//  IMGGalleryAlbum.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGGalleryAlbum.h"

@interface IMGGalleryAlbum ()

@property (readwrite, nonatomic) IMGVoteType vote;
@property (readwrite, nonatomic) NSString *section;
@property (readwrite, nonatomic) NSInteger ups;
@property (readwrite, nonatomic) NSInteger downs;
@property (readwrite, nonatomic) NSInteger score;
@property (readwrite, nonatomic) BOOL favorite;
@property (readwrite, nonatomic) BOOL nsfw;

@end

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

- (NSString *)description{
    
    return [NSString stringWithFormat: @"%@; ups: %ld; downs: %ld; score: %ld; vote: %ld", [super description], (long)self.ups, (long)self.downs, (long)self.score, (long)self.vote];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGGalleryAlbum class]]) {
        return NO;
    }
    
    return ([[object albumID] isEqualToString:self.albumID]);
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

-(NSString *)objectID{
    
    return self.albumID;
    
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSString * section = [decoder decodeObjectForKey:@"section"];
    IMGVoteType vote = [[decoder decodeObjectForKey:@"vote"] integerValue];
    NSInteger ups = [[decoder decodeObjectForKey:@"ups"] integerValue];
    NSInteger downs = [[decoder decodeObjectForKey:@"downs"] integerValue];
    NSInteger score = [[decoder decodeObjectForKey:@"score"] integerValue];
    BOOL favorite = [[decoder decodeObjectForKey:@"favorite"] boolValue];
    BOOL nsfw = [[decoder decodeObjectForKey:@"nsfw"] boolValue];
    
    if (self = [super initWithCoder:decoder]) {
        _vote = vote;
        _section = section;
        _ups = ups;
        _downs = downs;
        _score =  score;
        _favorite = favorite;
        _nsfw = nsfw;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.section forKey:@"section"];

    [coder encodeObject:@(self.vote) forKey:@"vote"];
    [coder encodeObject:@(self.ups) forKey:@"ups"];
    [coder encodeObject:@(self.downs) forKey:@"downs"];
    [coder encodeObject:@(self.score) forKey:@"score"];
    [coder encodeObject:@(self.favorite) forKey:@"favorite"];
    [coder encodeObject:@(self.nsfw) forKey:@"nsfw"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGGalleryAlbum *  copy = [super copyWithZone:zone];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setSection:[self.section copyWithZone:zone]];
        [copy setVote:self.vote];
        [copy setUps:self.ups];
        [copy setDowns:self.downs];
        [copy setScore:self.score];
        [copy setNsfw:self.nsfw];
        [copy setFavorite:self.favorite];
    }
    
    return copy;
}

@end
