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
@interface IMGComment : IMGModel <NSCopying,NSCoding>


/**
 Comment ID
 */
@property (readonly,nonatomic) NSInteger commentID;
/**
 Image ID comment is associated with
 */
@property (readonly,nonatomic, copy) NSString * imageID;
/**
 Actual comment string
 */
@property (readonly,nonatomic, copy) NSString * caption;
/**
 Authors username
 */
@property (readonly,nonatomic, copy) NSString * author;
/**
 Authors account id
 */
@property (readonly,nonatomic) NSInteger authorID;
/**
 Comment on an album, not image
 */
@property (readonly,nonatomic) BOOL onAlbum;
/**
 Album Cover Image Id, used for album comments
 */
@property (readonly,nonatomic, copy) NSString * albumCover;
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
@property (readonly,nonatomic) NSInteger points;
/**
 timestamp of creation of comment
 */
@property (readonly,nonatomic) NSDate * datetime;
/**
 Parent comment ID, nil if no parent
 */
@property (readonly,nonatomic) NSInteger parentID;
/**
 Is comment deleted? Still exists on server
 */
@property (readonly,nonatomic) BOOL deleted;
/**
 Responses to this comment. Only included with withReplies=YES
 */
@property (readonly,nonatomic, copy) NSArray * children;


@end
