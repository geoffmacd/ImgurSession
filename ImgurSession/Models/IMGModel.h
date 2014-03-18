//
//  IMGModel.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

typedef NS_ENUM(NSInteger, IMGVoteType) {
    IMGDownVote      = -1,
    IMGNeutralVote   = 0,
    IMGUpVote        = 1
};

typedef NS_ENUM(NSUInteger, IMGAlbumPrivacy){
    IMGAlbumDefault = 0,
    IMGAlbumPublic = 0,
    IMGAlbumHidden,
    IMGAlbumSecret
};

typedef NS_ENUM(NSUInteger, IMGAlbumLayout){
    IMGDefaultLayout = 0,
    IMGBlogLayout = 0,
    IMGGridLayout,
    IMGHorizontalLayout,
    IMGVerticalLayout
};


@interface IMGModel : NSObject

/**
 Common initializer for JSON HTTP response which processes the "data" JSON object into model object class
 @return initilialized instancetype object
 */
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

/**
 Intercept class to allow notification/delegates
 @return initilialized instancetype object
 */
- (instancetype)trackModels;

+(NSString*)strForVote:(IMGVoteType)vote;
+(IMGVoteType)voteForStr:(NSString*)voteStr;


@end
