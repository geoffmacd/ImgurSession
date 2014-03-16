//
//  IMGAccountSettings.h
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"


/**
 Model object class to represent blocked users from account settings
 */
@interface IMGBlockedUser : IMGModel

/**
 Blocked users Id
 */
@property (nonatomic) NSString *blockedId;
/**
 Blocked users URL for account page
 */
@property (nonatomic) NSString *blockedURL;

//initializer with a dictionary with just two keys
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error;

@end


/**
 Model object class to represent account settings. https://api.imgur.com/models/account_settings
 */
@interface IMGAccountSettings : IMGModel

/**
 User's email string.
 */
@property (nonatomic, readonly) NSString *email;
/**
 User's album privacy setting. If hidden, public cannot see user's albums.
 */
@property (nonatomic) IMGAlbumPrivacy albumPrivacy;
/**
 User allows all images submitted to be accessible to public.
 */
@property (nonatomic) BOOL publicImages;
/**
 Does user have Imgur regulated ability to upload high quality images
 */
@property (nonatomic) BOOL highQuality;
/**
 Expiry date or false if not a pro user
 */
@property (nonatomic,readonly) NSDate * proExpiration;
/**
 Has user accepted gallery submission terms?
 */
@property (nonatomic) BOOL acceptedGalleryTerms;
/**
 Array of email strings that are allowed to upload to imgur
 */
@property (nonatomic, readonly) NSArray *activeEmails;
/**
 Is user allowing incoming messages
 */
@property (nonatomic) BOOL messagingEnabled;
/**
 Array of blocked users with IMGBLockedUser model object.
 */
@property (nonatomic) NSArray *blockedUsers;


@end
