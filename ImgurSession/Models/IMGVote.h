//
//  IMGVote.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

typedef NS_ENUM(NSInteger, IMGVoteType) {
    IMGDownVote      = -1,
    IMGNeutralVote   = 0,
    IMGUpVote        = 1
};


/**
 Model object class to represent votes on images, albums, and comments. https://api.imgur.com/models/vote
 */
@interface IMGVote : IMGModel

/**
 up votes
 */
@property (readonly,nonatomic) NSInteger ups;
/**
 down votes
 */
@property (readonly,nonatomic) NSInteger downs;


+(NSString*)strForVote:(IMGVoteType)vote;
+(IMGVoteType)voteForStr:(NSString*)voteStr;

@end
