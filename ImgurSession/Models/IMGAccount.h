//
//  IMGAccount.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGModel.h"

/**
 Model object class to represent account settings. https://api.imgur.com/models/account
 */
@interface IMGAccount : IMGModel  <NSCopying,NSCoding>

/**
 Account ID
 */
@property (nonatomic, readonly) NSUInteger accountID;
/**
 Username string
 */
@property (nonatomic, readonly, copy) NSString *username;
/**
 URL link for account page
 */
@property (nonatomic, readonly) NSURL *url;
/**
 Biography string displayed on right pane on account page
 */
@property (nonatomic, readonly, copy) NSString *bio;
/**
 Reputation
 */
@property (nonatomic, readonly) float reputation;
/**
 Creation date for account
 */
@property (nonatomic, readonly) NSDate *created;

#pragma mark - Initializer
/**
 @param jsonData response "data" json Object for account
 @param username name of account
 @param error address of error object to output to
 @return signal with request
 */
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData withName:(NSString*)username error:(NSError * __autoreleasing *)error;



@end
