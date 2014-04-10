//
//  IMGGalleryImage.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGGalleryImage.h"

@interface IMGGalleryImage ()

@property (readwrite, nonatomic) IMGVoteType vote;
@property (readwrite, nonatomic) NSString *accountURL;
@property (readwrite, nonatomic) NSInteger ups;
@property (readwrite, nonatomic) NSInteger downs;
@property (readwrite, nonatomic) NSInteger score;
@property (readwrite, nonatomic) BOOL favorite;
@property (readwrite, nonatomic) BOOL nsfw;

@end

@implementation IMGGalleryImage;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    self = [super initWithJSONObject:jsonData error:error];
    
    if(self && !*error) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        }
        
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
        _score = [jsonData[@"score"] integerValue];
        _accountURL = jsonData[@"account_url"];
        if(![jsonData[@"vote"] isKindOfClass:[NSNull class]])
            _vote = [IMGVote voteForStr:jsonData[@"vote"]];
        else
            _vote = IMGNeutralVote;
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

-(NSString *)coverID{
    
    //for gallery image, the image is the cover image
    return self.imageID;
}

-(NSString *)objectID{
    
    return self.imageID;
}

-(NSString*)galleryDescription{
    
    return self.imageDescription;
}

-(NSString*)fromUsername{
    
    return self.accountURL;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSString * accountURL = [decoder decodeObjectForKey:@"accountURL"];
    IMGVoteType vote = [[decoder decodeObjectForKey:@"vote"] integerValue];
    NSInteger ups = [[decoder decodeObjectForKey:@"ups"] integerValue];
    NSInteger downs = [[decoder decodeObjectForKey:@"downs"] integerValue];
    NSInteger score = [[decoder decodeObjectForKey:@"score"] integerValue];
    BOOL favorite = [[decoder decodeObjectForKey:@"favorite"] boolValue];
    BOOL nsfw = [[decoder decodeObjectForKey:@"nsfw"] boolValue];
    
    if (self = [super initWithCoder:decoder]) {
        _vote = vote;
        _accountURL = accountURL;
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
    
    [coder encodeObject:self.accountURL forKey:@"accountURL"];
    
    [coder encodeObject:@(self.vote) forKey:@"vote"];
    [coder encodeObject:@(self.ups) forKey:@"ups"];
    [coder encodeObject:@(self.downs) forKey:@"downs"];
    [coder encodeObject:@(self.score) forKey:@"score"];
    [coder encodeObject:@(self.favorite) forKey:@"favorite"];
    [coder encodeObject:@(self.nsfw) forKey:@"nsfw"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGGalleryImage *  copy = [super copyWithZone:zone];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setAccountURL:[self.accountURL copyWithZone:zone]];
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
