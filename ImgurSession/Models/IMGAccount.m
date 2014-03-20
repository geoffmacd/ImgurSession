//
//  IMGAccount.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGAccount.h"
#import "IMGImage.h"
#import "IMGGalleryImage.h"
#import "IMGGalleryAlbum.h"
#import "IMGComment.h"
#import "IMGGalleryProfile.h"

@implementation IMGAccount;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error{
    
    return [self initWithJSONObject:jsonData withName:@"me" error:error];;
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData withName:(NSString *)username error:(NSError * __autoreleasing *)error{
    
    if(self = [super init]) {
        
        _username = username;
        _accountID = [jsonData[@"id"] integerValue];
        _url = [NSURL URLWithString:jsonData[@"url"]];
        _bio = jsonData[@"bio"];
        _reputation = [jsonData[@"reputation"] floatValue];
        _created = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"created"] integerValue]];
    }
    return [self trackModels];
}


#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat: @"%@; accountID: %lu; url: \"%@\"; bio: \"%@\"; reputation: %.2f; created: %@", [super description], (unsigned long)self.accountID, self.url, self.bio, self.reputation, self.created];
}




@end
