//
//  IMGComment.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

/**
 Model object class to represent comments on images, albums, and comments. https://api.imgur.com/models/comment
 */
@interface IMGComment : IMGModel

/**
 Comment ID
 */
@property (readonly,nonatomic) NSString * commentId;
/**
 Image ID comment is associated with
 */
@property (readonly,nonatomic) NSString * imageId;
/**
 Actual comment string
 */
@property (readonly,nonatomic) NSString * caption;
/**
 Authors username
 */
@property (readonly,nonatomic) NSString * author;
/**
 Authors account id
 */
@property (readonly,nonatomic) NSInteger authorId;
/**
 Comment on an album, not image
 */
@property (readonly,nonatomic) BOOL onAlbum;
/**
 Album Cover Image Id, used for album comments
 */
@property (readonly,nonatomic) NSString * albumCover;
/**
 Up-votes
 */
@property (readonly,nonatomic) NSInteger ups;
/**
 down-votes
 */
@property (readonly,nonatomic) NSInteger downs;
/**
 sum of up-votes minus down-votes
 */
@property (readonly,nonatomic) CGFloat points;
/**
 timestamp of creation of comment
 */
@property (readonly,nonatomic) NSDate* datetime;
/**
 Parent comment ID, nil if no parent
 */
@property (readonly,nonatomic) NSInteger parentId;
/**
 Is comment deleted? Still exists on server
 */
@property (readonly,nonatomic) BOOL deleted;
/**
 Responses to this comment. Only included with withReplies=YES
 */
@property (readonly,nonatomic) NSArray * children;


@end
