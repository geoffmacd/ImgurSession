//
//  IMGAccountSettings.m
//  ImgurKit
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGAccount.h"
#import "IMGAccountSettings.h"
#import "IMGBasicAlbum.h"


@implementation IMGBlockedUser

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error{
    
    if(self = [super init]) {
        _blockedId = jsonData[@"blocked_id"];
        _blockedURL = jsonData[@"blocked_url"];
    }
    return [self trackModels];
}

@end

@implementation IMGAccountSettings

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error{
    
    if(self = [super init]) {
        
        _email = jsonData[@"email"];
        _albumPrivacy = [IMGBasicAlbum privacyForStr:jsonData[@"album_privacy"]];
        _publicImages = [jsonData[@"public_images"] integerValue];
        _highQuality = [jsonData[@"high_quality"] integerValue];
        if([jsonData[@"pro_expiration"] integerValue])
            _proExpiration = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"pro_expiration"] integerValue]];
        else
            _proExpiration = nil;
        _acceptedGalleryTerms = [jsonData[@"accepted_gallery_terms"] integerValue];
        
        //enumerate all active emails
        NSMutableArray * activeEmails = [NSMutableArray new];
        for(NSString * email in jsonData[@"active_emails"]){
            [activeEmails addObject:email];
        }
        _activeEmails = activeEmails;
        _messagingEnabled = [jsonData[@"messaging_enabled"] integerValue];
        
        //enumerate all blocked users
        NSMutableArray * blockedUsers = [NSMutableArray new];
        for(NSDictionary * user in jsonData[@"blocked_users"]){
            IMGBlockedUser * blocked = [[IMGBlockedUser alloc] initWithJSONObject:user error:nil];
            [blockedUsers addObject:blocked];
        }
        _blockedUsers = blockedUsers;
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat: @"%@; email: \"%@\"; high quality: \"%@\"; album_privact: \"%@\"",  [super description], _email, (_highQuality ? @"YES" : @"NO"), [IMGBasicAlbum strForPrivacy:_albumPrivacy]];
}




@end
