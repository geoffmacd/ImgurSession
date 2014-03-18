//
//  IMGModel.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"
#import "IMGSession.h"

@implementation IMGModel

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    NSAssert(NO, @"Should be overridden by subclass");
    return nil;
}

-(instancetype)trackModels{
    
    [[IMGSession sharedInstance] trackModelObjectsForDelegateHandling:self];
    
    return self;
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
