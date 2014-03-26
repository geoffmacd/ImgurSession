//
//  IMGGalleryProfile.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGGalleryProfile.h"



@implementation IMGGalleryTrophy

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        _trophyId = jsonData[@"id"];
        _name = jsonData[@"name"];
        _type = jsonData[@"name_clean"];
        _profileDescription = jsonData[@"description"];
        _data = jsonData[@"data"];
        _link = [NSURL URLWithString:jsonData[@"data_link"]];
        _dateAwarded = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _imageUrl = [NSURL URLWithString:jsonData[@"image"]];
    }
    return [self trackModels];
}


@end

@implementation IMGGalleryProfile


#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        _totalComments = [jsonData[@"total_gallery_comments"] integerValue];
        _totalLikes = [jsonData[@"total_gallery_likes"] integerValue];
        _totalSubmissions = [jsonData[@"total_gallery_submissions"] integerValue];
        
        //enumerate all blocked users
        NSMutableArray * trophies = [NSMutableArray new];
        for(NSDictionary * trophyJSON in jsonData[@"trophies"]){
            IMGGalleryTrophy * trophy = [[IMGGalleryTrophy alloc] initWithJSONObject:trophyJSON error:nil];
            [trophies addObject:trophy];
        }
        _trophies = trophies;

    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@; comments: %ld; likes: %ld; submissions: %ld; trophies: %ld;",  [super description],(long)self.totalComments, (long)self.totalLikes, (long)self.totalSubmissions, (long)[self.trophies count]];
}



@end
