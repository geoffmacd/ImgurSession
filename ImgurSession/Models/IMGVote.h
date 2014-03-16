//
//  IMGVote.h
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

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



@end
