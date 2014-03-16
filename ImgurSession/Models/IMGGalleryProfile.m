//
//  IMGGalleryProfile.m
//  ImgurKit
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
        _description = jsonData[@"description"];
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
        _totalLIMGes = [jsonData[@"total_gallery_lIMGes"] integerValue];
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
    return [NSString stringWithFormat:@"%@; comments: %ld; lIMGes: %ld; submissions: %ld; trophies: %ld;",  [super description],(long)_totalComments, (long)_totalLIMGes, (long)_totalSubmissions, (long)[_trophies count]];
}



@end
