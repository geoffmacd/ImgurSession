//
//  IMGVote.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGVote.h"

@implementation IMGVote

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@; ups: \"%ld\"; downs: \"%ld\";",  [super description], (long)self.ups, (long)self.downs];
}

+(NSString*)strForVote:(IMGVoteType)vote{
    NSString * str;
    switch (vote) {
        case IMGDownVote:
            str = @"down";
            break;
            
        case IMGUpVote:
            str = @"up";
            break;
        case IMGNeutralVote:
            str = @"";
            break;
        default:
            break;
    }
    return str;
}

+(IMGVoteType)voteForStr:(NSString*)voteStr{
    
    if([voteStr isEqualToString:@"up"])
        return IMGUpVote;
    else if([voteStr isEqualToString:@"down"])
        return IMGDownVote;
    else
        return IMGNeutralVote;
}

@end
